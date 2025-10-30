#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_test_env() {
    TEST_DIR=$(mktemp -d)
    export CONFIG_DIR="$TEST_DIR/config"
    mkdir -p "$CONFIG_DIR"
    
    echo "Test environment setup:"
    echo "  Repo: $SCRIPT_DIR"
    echo "  Test config dir: $CONFIG_DIR"
    echo ""
}

cleanup_test_env() {
    if [ -n "${TEST_DIR:-}" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

test_start() {
    local test_name=$1
    echo -n "Testing: $test_name ... "
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_pass() {
    echo -e "${GREEN}PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    local message=$1
    echo -e "${RED}FAIL${NC}"
    echo "  Error: $message"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

get_available_tools() {
    local tools=()
    for dir in "$SCRIPT_DIR"/*; do
        if [ -d "$dir" ] && [ "$(basename "$dir")" != ".git" ] && [ "$(basename "$dir")" != ".github" ]; then
            tools+=("$(basename "$dir")")
        fi
    done
    echo "${tools[@]}"
}

test_default_recipe() {
    test_start "default recipe (should link all tools)"
    
    output=$(cd "$SCRIPT_DIR" && just 2>&1 || true)
    
    local tools=($(get_available_tools))
    local all_linked=true
    
    for tool in "${tools[@]}"; do
        if [ ! -L "$CONFIG_DIR/$tool" ]; then
            all_linked=false
            break
        fi
    done
    
    if [ "$all_linked" = true ]; then
        test_pass
    else
        test_fail "Not all tools were linked by default recipe"
    fi
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
}

test_help_recipe() {
    test_start "help recipe"
    
    output=$(cd "$SCRIPT_DIR" && just help 2>&1)
    
    if echo "$output" | grep -q "Config Management Tool" && \
       echo "$output" | grep -q "Usage:" && \
       echo "$output" | grep -q "just link" && \
       echo "$output" | grep -q "just unlink" && \
       echo "$output" | grep -q "just status" && \
       echo "$output" | grep -q "just list"; then
        test_pass
    else
        test_fail "Help output missing expected content"
    fi
}

test_list_recipe() {
    test_start "list recipe"
    
    output=$(cd "$SCRIPT_DIR" && just list 2>&1)
    
    local tools=($(get_available_tools))
    local all_listed=true
    
    for tool in "${tools[@]}"; do
        if ! echo "$output" | grep -q "$tool"; then
            all_listed=false
            break
        fi
    done
    
    if [ "$all_listed" = true ] && echo "$output" | grep -q "Available tool configurations:"; then
        test_pass
    else
        test_fail "List output missing expected tools"
    fi
}

test_link_all() {
    test_start "link all tools"
    
    cd "$SCRIPT_DIR" && just link >/dev/null 2>&1
    
    local tools=($(get_available_tools))
    local all_linked=true
    
    for tool in "${tools[@]}"; do
        if [ ! -L "$CONFIG_DIR/$tool" ]; then
            all_linked=false
            break
        fi
        
        local link_target=$(readlink "$CONFIG_DIR/$tool")
        local expected_target="$SCRIPT_DIR/$tool"
        if [ "$link_target" != "$expected_target" ]; then
            all_linked=false
            break
        fi
    done
    
    if [ "$all_linked" = true ]; then
        test_pass
    else
        test_fail "Not all tools were linked correctly"
    fi
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
}

test_link_specific() {
    test_start "link specific tool"
    
    local tools=($(get_available_tools))
    local test_tool="${tools[0]}"
    
    cd "$SCRIPT_DIR" && just link "$test_tool" >/dev/null 2>&1
    
    if [ -L "$CONFIG_DIR/$test_tool" ]; then
        local link_target=$(readlink "$CONFIG_DIR/$test_tool")
        local expected_target="$SCRIPT_DIR/$test_tool"
        
        if [ "$link_target" = "$expected_target" ]; then
            local only_one_linked=true
            for tool in "${tools[@]}"; do
                if [ "$tool" != "$test_tool" ] && [ -L "$CONFIG_DIR/$tool" ]; then
                    only_one_linked=false
                    break
                fi
            done
            
            if [ "$only_one_linked" = true ]; then
                test_pass
            else
                test_fail "Other tools were linked when only one should be"
            fi
        else
            test_fail "Tool linked to wrong location"
        fi
    else
        test_fail "Specific tool was not linked"
    fi
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
}

test_link_some() {
    test_start "link some but not all tools"
    
    local tools=($(get_available_tools))
    
    if [ ${#tools[@]} -ge 2 ]; then
        cd "$SCRIPT_DIR" && just link "${tools[0]}" >/dev/null 2>&1
        cd "$SCRIPT_DIR" && just link "${tools[1]}" >/dev/null 2>&1
        
        local linked_count=0
        for tool in "${tools[@]}"; do
            if [ -L "$CONFIG_DIR/$tool" ]; then
                linked_count=$((linked_count + 1))
            fi
        done
        
        if [ $linked_count -eq 2 ]; then
            test_pass
        else
            test_fail "Expected 2 tools linked, found $linked_count"
        fi
    else
        test_pass
        echo "  (Skipped: less than 2 tools available)"
    fi
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
}

test_status_linked() {
    test_start "status recipe (with linked tools)"
    
    cd "$SCRIPT_DIR" && just link >/dev/null 2>&1
    
    output=$(cd "$SCRIPT_DIR" && just status 2>&1)
    
    local tools=($(get_available_tools))
    local all_shown_linked=true
    
    for tool in "${tools[@]}"; do
        if ! echo "$output" | grep -q "✓ $tool → linked"; then
            all_shown_linked=false
            break
        fi
    done
    
    if [ "$all_shown_linked" = true ] && \
       echo "$output" | grep -q "Configuration status:" && \
       echo "$output" | grep -q "Repo: $SCRIPT_DIR" && \
       echo "$output" | grep -q "Target: $CONFIG_DIR"; then
        test_pass
    else
        test_fail "Status output incorrect for linked tools"
    fi
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
}

test_status_unlinked() {
    test_start "status recipe (with unlinked tools)"
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
    
    output=$(cd "$SCRIPT_DIR" && just status 2>&1)
    
    local tools=($(get_available_tools))
    local all_shown_unlinked=true
    
    for tool in "${tools[@]}"; do
        if ! echo "$output" | grep -q "$tool.*not linked"; then
            all_shown_unlinked=false
            break
        fi
    done
    
    if [ "$all_shown_unlinked" = true ]; then
        test_pass
    else
        test_fail "Status output incorrect for unlinked tools"
    fi
}

test_unlink_all() {
    test_start "unlink all tools"
    
    cd "$SCRIPT_DIR" && just link >/dev/null 2>&1
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1
    
    local tools=($(get_available_tools))
    local all_unlinked=true
    
    for tool in "${tools[@]}"; do
        if [ -L "$CONFIG_DIR/$tool" ]; then
            all_unlinked=false
            break
        fi
    done
    
    if [ "$all_unlinked" = true ]; then
        test_pass
    else
        test_fail "Not all tools were unlinked"
    fi
}

test_unlink_specific() {
    test_start "unlink specific tool"
    
    cd "$SCRIPT_DIR" && just link >/dev/null 2>&1
    
    local tools=($(get_available_tools))
    local test_tool="${tools[0]}"
    
    cd "$SCRIPT_DIR" && just unlink "$test_tool" >/dev/null 2>&1
    
    if [ ! -L "$CONFIG_DIR/$test_tool" ]; then
        local others_still_linked=true
        for tool in "${tools[@]}"; do
            if [ "$tool" != "$test_tool" ] && [ ! -L "$CONFIG_DIR/$tool" ]; then
                others_still_linked=false
                break
            fi
        done
        
        if [ "$others_still_linked" = true ]; then
            test_pass
        else
            test_fail "Other tools were unlinked when only one should be"
        fi
    else
        test_fail "Specific tool was not unlinked"
    fi
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
}

test_unlink_some() {
    test_start "unlink some but not all tools"
    
    cd "$SCRIPT_DIR" && just link >/dev/null 2>&1
    
    local tools=($(get_available_tools))
    
    if [ ${#tools[@]} -ge 2 ]; then
        cd "$SCRIPT_DIR" && just unlink "${tools[0]}" >/dev/null 2>&1
        cd "$SCRIPT_DIR" && just unlink "${tools[1]}" >/dev/null 2>&1
        
        local unlinked_count=0
        for tool in "${tools[@]}"; do
            if [ ! -L "$CONFIG_DIR/$tool" ]; then
                unlinked_count=$((unlinked_count + 1))
            fi
        done
        
        if [ $unlinked_count -eq 2 ]; then
            test_pass
        else
            test_fail "Expected 2 tools unlinked, found $unlinked_count"
        fi
    else
        test_pass
        echo "  (Skipped: less than 2 tools available)"
    fi
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
}

test_config_dir_env() {
    test_start "CONFIG_DIR environment variable"
    
    cd "$SCRIPT_DIR" && just link >/dev/null 2>&1
    
    local tools=($(get_available_tools))
    local using_custom_dir=true
    
    for tool in "${tools[@]}"; do
        if [ ! -L "$CONFIG_DIR/$tool" ]; then
            using_custom_dir=false
            break
        fi
    done
    
    local default_config="$HOME/.config"
    local nothing_in_default=true
    for tool in "${tools[@]}"; do
        if [ -L "$default_config/$tool" ]; then
            local link_target=$(readlink "$default_config/$tool")
            if [ "$link_target" = "$SCRIPT_DIR/$tool" ]; then
                nothing_in_default=false
                break
            fi
        fi
    done
    
    if [ "$using_custom_dir" = true ] && [ "$nothing_in_default" = true ]; then
        test_pass
    else
        test_fail "CONFIG_DIR environment variable not respected"
    fi
    
    cd "$SCRIPT_DIR" && just unlink >/dev/null 2>&1 || true
}

main() {
    echo "=========================================="
    echo "Dotconfig Test Bench"
    echo "=========================================="
    echo ""
    
    setup_test_env
    
    test_help_recipe
    test_list_recipe
    test_link_all
    test_link_specific
    test_link_some
    test_status_linked
    test_status_unlinked
    test_unlink_specific
    test_unlink_some
    test_unlink_all
    test_config_dir_env
    test_default_recipe
    
    cleanup_test_env
    
    echo ""
    echo "=========================================="
    echo "Test Summary"
    echo "=========================================="
    echo "Tests run:    $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        exit 1
    fi
}

main
