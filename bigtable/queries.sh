#!/bin/bash

# Highlands Coffee - Common Bigtable Query Examples
# This script demonstrates common query patterns

echo "========================================="
echo "Common Bigtable Query Examples"
echo "========================================="
echo ""

# 1. List all tables
echo "1. List all tables:"
echo "   cbt ls"
echo ""

# 2. Read a specific user
echo "2. Read a specific user:"
echo "   cbt read users prefix=user#test001"
echo ""

# 3. List all products
echo "3. List all products:"
echo "   cbt read products"
echo ""

# 4. Get products by category (requires filtering in application)
echo "4. Get products by category:"
echo "   cbt read products | grep 'info:category=\"coffee\"'"
echo ""

# 5. List all stores
echo "5. List all stores:"
echo "   cbt read stores"
echo ""

# 6. Get orders for a specific user
echo "6. Get orders for a specific user:"
echo "   cbt read orders_by_user prefix=user#test001#order#"
echo ""

# 7. Get recent orders (time-range scan)
echo "7. Get recent orders:"
echo "   cbt read orders start=order#9223370 end=order#9223371"
echo ""

# 8. Get a specific order
echo "8. Get a specific order:"
echo "   cbt read orders prefix=order#9223370482312345678#ord001"
echo ""

# 9. Count rows in a table
echo "9. Count rows in a table:"
echo "   cbt count products"
echo ""

# 10. Delete a row
echo "10. Delete a row:"
echo "    cbt deletetable <table_name> <row_key>"
echo ""

# 11. Lookup by row key
echo "11. Lookup by exact row key:"
echo "    cbt lookup users user#test001"
echo ""

# 12. Read with column filter
echo "12. Read specific columns:"
echo "    cbt read users columns=profile:name,profile:email"
echo ""

echo ""
echo "========================================="
echo "Execute any of these commands to query data"
echo "========================================="
echo ""

# Interactive menu
echo "Would you like to run a sample query? (y/n)"
read -r response

if [ "$response" = "y" ]; then
    echo ""
    echo "Select a query to run:"
    echo "1. List all products"
    echo "2. List all stores"
    echo "3. View test user"
    echo "4. Count products"
    echo ""
    read -r choice

    case $choice in
        1)
            echo "Executing: cbt read products"
            cbt read products
            ;;
        2)
            echo "Executing: cbt read stores"
            cbt read stores
            ;;
        3)
            echo "Executing: cbt lookup users user#test001"
            cbt lookup users user#test001
            ;;
        4)
            echo "Executing: cbt count products"
            cbt count products
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
fi

echo ""
echo "For more information, run: cbt help"
echo ""

