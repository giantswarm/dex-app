#!/bin/bash

# Dex App Refactoring Validation Script
# This script helps validate that the refactored chart produces the same output

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CHART_PATH="./helm/dex-app"
TEST_VALUES="./tests/test-values.yaml"
NAMESPACE="dex"
TEMP_DIR=$(mktemp -d)

echo "🔍 Dex App Refactoring Validation Script"
echo "========================================"

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "success")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "error")
            echo -e "${RED}✗${NC} $message"
            ;;
        "warning")
            echo -e "${YELLOW}!${NC} $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

# Function to generate manifests
generate_manifests() {
    local output_file=$1
    local extra_args=${2:-""}
    
    helm template dex-app "$CHART_PATH" \
        -f "$TEST_VALUES" \
        --namespace "$NAMESPACE" \
        $extra_args \
        > "$output_file" 2>&1 || {
            print_status "error" "Failed to generate manifests"
            cat "$output_file"
            return 1
        }
}

# Function to extract and sort resources
extract_resources() {
    local manifest_file=$1
    local output_dir=$2
    
    # Split manifests by resource
    awk '/^---$/ { close(file); file=sprintf("'$output_dir'/resource-%03d.yaml", ++i) } 
         { print > file }' "$manifest_file"
    
    # Sort resources by kind and name
    for file in "$output_dir"/*.yaml; do
        if [[ -f "$file" ]]; then
            kind=$(grep "^kind:" "$file" | awk '{print $2}')
            name=$(grep "^  name:" "$file" | head -1 | awk '{print $2}')
            if [[ -n "$kind" && -n "$name" ]]; then
                mv "$file" "$output_dir/${kind}-${name}.yaml"
            fi
        fi
    done
}

# Function to compare specific resource types
compare_resources() {
    local before_dir=$1
    local after_dir=$2
    local resource_type=$3
    
    echo -e "\n📋 Comparing $resource_type resources:"
    
    local has_differences=false
    
    for file in "$before_dir"/${resource_type}-*.yaml; do
        if [[ -f "$file" ]]; then
            local basename=$(basename "$file")
            local after_file="$after_dir/$basename"
            
            if [[ -f "$after_file" ]]; then
                if ! diff -q "$file" "$after_file" > /dev/null; then
                    print_status "warning" "$basename has changes"
                    has_differences=true
                fi
            else
                print_status "error" "$basename missing in new version"
                has_differences=true
            fi
        fi
    done
    
    # Check for new resources
    for file in "$after_dir"/${resource_type}-*.yaml; do
        if [[ -f "$file" ]]; then
            local basename=$(basename "$file")
            local before_file="$before_dir/$basename"
            
            if [[ ! -f "$before_file" ]]; then
                print_status "warning" "$basename is new in refactored version"
                has_differences=true
            fi
        fi
    done
    
    if ! $has_differences; then
        print_status "success" "No changes in $resource_type resources"
    fi
}

# Function to validate selectors
validate_selectors() {
    local manifest_file=$1
    
    echo -e "\n🔍 Validating selectors:"
    
    # Extract deployment selectors
    local deployments=$(grep -A 10 "kind: Deployment" "$manifest_file" | grep -A 5 "selector:" | grep "app.kubernetes.io" | sort | uniq)
    
    # Extract service selectors
    local services=$(grep -A 10 "kind: Service" "$manifest_file" | grep -A 5 "selector:" | grep "app.kubernetes.io" | sort | uniq)
    
    # Compare
    if [[ "$deployments" == "$services" ]]; then
        print_status "success" "Deployment and Service selectors match"
    else
        print_status "error" "Deployment and Service selectors don't match"
        echo "Deployment selectors:"
        echo "$deployments"
        echo "Service selectors:"
        echo "$services"
    fi
}

# Function to check for deprecated APIs
check_deprecated_apis() {
    local manifest_file=$1
    
    echo -e "\n🔍 Checking for deprecated APIs:"
    
    local deprecated_found=false
    
    # Check for deprecated API versions
    if grep -q "apiVersion: extensions/v1beta1" "$manifest_file"; then
        print_status "warning" "Found deprecated extensions/v1beta1 API"
        deprecated_found=true
    fi
    
    if grep -q "apiVersion: networking.k8s.io/v1beta1" "$manifest_file"; then
        print_status "warning" "Found deprecated networking.k8s.io/v1beta1 API"
        deprecated_found=true
    fi
    
    if ! $deprecated_found; then
        print_status "success" "No deprecated APIs found"
    fi
}

# Main execution
main() {
    # Step 1: Check if chart exists
    if [[ ! -d "$CHART_PATH" ]]; then
        print_status "error" "Chart not found at $CHART_PATH"
        exit 1
    fi
    
    # Step 2: Generate manifests for current version
    echo -e "\n📦 Generating manifests..."
    
    local current_manifests="$TEMP_DIR/current-manifests.yaml"
    if ! generate_manifests "$current_manifests"; then
        exit 1
    fi
    print_status "success" "Generated manifests successfully"
    
    # Step 3: Extract and organize resources
    echo -e "\n📂 Organizing resources..."
    
    local current_resources="$TEMP_DIR/current-resources"
    mkdir -p "$current_resources"
    extract_resources "$current_manifests" "$current_resources"
    
    # Step 4: Validate current manifests
    validate_selectors "$current_manifests"
    check_deprecated_apis "$current_manifests"
    
    # Step 5: Test different configurations
    echo -e "\n🧪 Testing different configurations:"
    
    # Test management cluster config
    local mgmt_manifests="$TEMP_DIR/mgmt-manifests.yaml"
    if generate_manifests "$mgmt_manifests" "--set isManagementCluster=true --set managementCluster.name=test-mc"; then
        print_status "success" "Management cluster configuration works"
    else
        print_status "error" "Management cluster configuration failed"
    fi
    
    # Test workload cluster config
    local wc_manifests="$TEMP_DIR/wc-manifests.yaml"
    if generate_manifests "$wc_manifests" "--set isWorkloadCluster=true --set clusterID=test-wc --set baseDomain=example.com"; then
        print_status "success" "Workload cluster configuration works"
    else
        print_status "error" "Workload cluster configuration failed"
    fi
    
    # Step 6: Resource count summary
    echo -e "\n📊 Resource Summary:"
    for kind in Deployment Service Ingress ConfigMap Secret ServiceAccount ClusterRole ClusterRoleBinding; do
        count=$(grep -c "kind: $kind" "$current_manifests" || true)
        if [[ $count -gt 0 ]]; then
            echo "  - $kind: $count"
        fi
    done
    
    # Step 7: Check for required resources
    echo -e "\n✅ Checking required resources:"
    
    required_resources=(
        "Deployment-dex"
        "Service-dex"
        "Ingress-dex"
        "Secret-dex"
        "ServiceAccount-dex"
    )
    
    for resource in "${required_resources[@]}"; do
        if [[ -f "$current_resources/$resource.yaml" ]]; then
            print_status "success" "$resource exists"
        else
            print_status "error" "$resource missing"
        fi
    done
    
    # Step 8: Check dex-k8s-authenticator if enabled
    if grep -q "deployDexK8SAuthenticator: true" "$TEST_VALUES"; then
        echo -e "\n🔍 Checking dex-k8s-authenticator resources:"
        
        auth_resources=(
            "Deployment-dex-k8s-authenticator"
            "Service-dex-k8s-authenticator"
            "ConfigMap-dex-k8s-authenticator"
        )
        
        for resource in "${auth_resources[@]}"; do
            if ls "$current_resources"/*${resource}*.yaml 1> /dev/null 2>&1; then
                print_status "success" "$resource exists"
            else
                print_status "error" "$resource missing"
            fi
        done
    fi
    
    # Cleanup
    echo -e "\n🧹 Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    
    echo -e "\n✨ Validation complete!"
}

# Run main function
main "$@"