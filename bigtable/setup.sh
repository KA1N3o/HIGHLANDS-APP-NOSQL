#!/bin/bash

# Highlands Coffee - Google Bigtable Setup Script
# This script sets up the Bigtable instance and tables for the application

set -e

# Configuration
PROJECT_ID="your-gcp-project-id"
INSTANCE_ID="highlands-coffee"
CLUSTER_ID="highlands-coffee-cluster"
ZONE="asia-southeast1-a"
STORAGE_TYPE="SSD"
NUM_NODES=3

echo "========================================="
echo "Highlands Coffee - Bigtable Setup"
echo "========================================="
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI not found. Please install it first."
    exit 1
fi

# Check if cbt is installed
if ! command -v cbt &> /dev/null; then
    echo "Error: cbt tool not found. Installing..."
    gcloud components install cbt
fi

# Set project
echo "Setting project to: $PROJECT_ID"
gcloud config set project $PROJECT_ID

# Create Bigtable instance
echo ""
echo "Creating Bigtable instance: $INSTANCE_ID"
gcloud bigtable instances create $INSTANCE_ID \
    --cluster=$CLUSTER_ID \
    --cluster-zone=$ZONE \
    --cluster-num-nodes=$NUM_NODES \
    --cluster-storage-type=$STORAGE_TYPE \
    --display-name="Highlands Coffee Production" \
    || echo "Instance may already exist, continuing..."

# Configure cbt
echo ""
echo "Configuring cbt tool..."
echo "project = $PROJECT_ID" > ~/.cbtrc
echo "instance = $INSTANCE_ID" >> ~/.cbtrc

# Create tables
echo ""
echo "Creating tables..."

# 1. Users table
echo "  - Creating 'users' table..."
cbt createtable users || echo "Table 'users' may already exist"
cbt createfamily users profile
cbt createfamily users auth
cbt setgcpolicy users profile maxversions=1
cbt setgcpolicy users auth maxversions=1

# 2. Products table
echo "  - Creating 'products' table..."
cbt createtable products || echo "Table 'products' may already exist"
cbt createfamily products info
cbt createfamily products options
cbt setgcpolicy products info maxversions=1
cbt setgcpolicy products options maxversions=1

# 3. Stores table
echo "  - Creating 'stores' table..."
cbt createtable stores || echo "Table 'stores' may already exist"
cbt createfamily stores info
cbt createfamily stores hours
cbt setgcpolicy stores info maxversions=1
cbt setgcpolicy stores hours maxversions=1

# 4. Orders table
echo "  - Creating 'orders' table..."
cbt createtable orders || echo "Table 'orders' may already exist"
cbt createfamily orders info
cbt createfamily orders payment
cbt createfamily orders items
cbt setgcpolicy orders info maxversions=1
cbt setgcpolicy orders payment maxversions=1
cbt setgcpolicy orders items maxversions=1

# 5. Orders by user index
echo "  - Creating 'orders_by_user' table..."
cbt createtable orders_by_user || echo "Table 'orders_by_user' may already exist"
cbt createfamily orders_by_user ref
cbt setgcpolicy orders_by_user ref maxversions=1

# 6. Sessions table
echo "  - Creating 'sessions' table..."
cbt createtable sessions || echo "Table 'sessions' may already exist"
cbt createfamily sessions data
cbt setgcpolicy sessions data maxage=30d

echo ""
echo "========================================="
echo "Setup completed successfully!"
echo "========================================="
echo ""
echo "Instance ID: $INSTANCE_ID"
echo "Cluster ID: $CLUSTER_ID"
echo "Zone: $ZONE"
echo ""
echo "Tables created:"
echo "  - users"
echo "  - products"
echo "  - stores"
echo "  - orders"
echo "  - orders_by_user"
echo "  - sessions"
echo ""
echo "Next steps:"
echo "1. Run './seed_data.sh' to populate sample data"
echo "2. Update API service with your instance details"
echo "3. Configure authentication in your Flutter app"
echo ""

