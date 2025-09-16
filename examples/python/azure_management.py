#!/usr/bin/env python3
"""
Azure Management Automation Script

This script demonstrates Python best practices for Azure resource management
including proper logging, error handling, and configuration management.

Author: DevOps Team
Date: 2024
Version: 1.0
"""

import argparse
import logging
import sys
from typing import Optional, Dict, Any
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.core.exceptions import AzureError


def setup_logging(log_level: str = "INFO") -> logging.Logger:
    """
    Setup structured logging configuration.
    
    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR)
        
    Returns:
        Configured logger instance
    """
    logger = logging.getLogger(__name__)
    logger.setLevel(getattr(logging, log_level.upper()))
    
    # Create console handler with formatting
    handler = logging.StreamHandler(sys.stdout)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    
    return logger


class AzureResourceManager:
    """
    Azure Resource Management class with best practices implementation.
    """
    
    def __init__(self, subscription_id: str, logger: logging.Logger):
        """
        Initialize Azure Resource Manager.
        
        Args:
            subscription_id: Azure subscription ID
            logger: Logger instance
        """
        self.subscription_id = subscription_id
        self.logger = logger
        self.credential = DefaultAzureCredential()
        self.resource_client = ResourceManagementClient(
            self.credential, subscription_id
        )
    
    def create_resource_group(
        self, 
        resource_group_name: str, 
        location: str, 
        tags: Optional[Dict[str, str]] = None
    ) -> bool:
        """
        Create or update an Azure Resource Group.
        
        Args:
            resource_group_name: Name of the resource group
            location: Azure region
            tags: Optional resource tags
            
        Returns:
            True if successful, False otherwise
        """
        try:
            self.logger.info(f"Creating resource group: {resource_group_name}")
            
            # Prepare resource group parameters
            rg_params = {
                'location': location,
                'tags': tags or {}
            }
            
            # Create resource group
            result = self.resource_client.resource_groups.create_or_update(
                resource_group_name, rg_params
            )
            
            self.logger.info(f"Resource group created successfully: {result.name}")
            return True
            
        except AzureError as e:
            self.logger.error(f"Azure error creating resource group: {e}")
            return False
        except Exception as e:
            self.logger.error(f"Unexpected error: {e}")
            return False
    
    def list_resource_groups(self) -> Optional[list]:
        """
        List all resource groups in the subscription.
        
        Returns:
            List of resource group names or None if error
        """
        try:
            self.logger.info("Listing resource groups")
            
            resource_groups = []
            for rg in self.resource_client.resource_groups.list():
                resource_groups.append({
                    'name': rg.name,
                    'location': rg.location,
                    'tags': rg.tags or {}
                })
            
            self.logger.info(f"Found {len(resource_groups)} resource groups")
            return resource_groups
            
        except AzureError as e:
            self.logger.error(f"Azure error listing resource groups: {e}")
            return None
        except Exception as e:
            self.logger.error(f"Unexpected error: {e}")
            return None


def main():
    """
    Main function with argument parsing and execution logic.
    """
    parser = argparse.ArgumentParser(
        description="Azure Resource Management Automation"
    )
    parser.add_argument(
        '--action',
        choices=['create', 'list'],
        required=True,
        help='Action to perform'
    )
    parser.add_argument(
        '--subscription-id',
        required=True,
        help='Azure subscription ID'
    )
    parser.add_argument(
        '--resource-group',
        help='Resource group name (required for create action)'
    )
    parser.add_argument(
        '--location',
        default='West Europe',
        help='Azure location (default: West Europe)'
    )
    parser.add_argument(
        '--environment',
        choices=['dev', 'staging', 'prod'],
        default='dev',
        help='Environment (default: dev)'
    )
    parser.add_argument(
        '--log-level',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'],
        default='INFO',
        help='Logging level (default: INFO)'
    )
    
    args = parser.parse_args()
    
    # Setup logging
    logger = setup_logging(args.log_level)
    
    try:
        # Initialize Azure Resource Manager
        arm = AzureResourceManager(args.subscription_id, logger)
        
        # Execute requested action
        if args.action == 'create':
            if not args.resource_group:
                logger.error("Resource group name is required for create action")
                sys.exit(1)
            
            # Generate environment-specific tags
            tags = {
                'Environment': args.environment,
                'ManagedBy': 'DevOps-Automation',
                'Project': 'DevOps-Tools'
            }
            
            success = arm.create_resource_group(
                args.resource_group, 
                args.location, 
                tags
            )
            
            if success:
                logger.info("Resource group creation completed successfully")
                sys.exit(0)
            else:
                logger.error("Resource group creation failed")
                sys.exit(1)
        
        elif args.action == 'list':
            resource_groups = arm.list_resource_groups()
            
            if resource_groups is not None:
                logger.info("Resource Groups:")
                for rg in resource_groups:
                    logger.info(f"  - {rg['name']} ({rg['location']})")
                sys.exit(0)
            else:
                logger.error("Failed to list resource groups")
                sys.exit(1)
    
    except KeyboardInterrupt:
        logger.info("Operation cancelled by user")
        sys.exit(130)
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()