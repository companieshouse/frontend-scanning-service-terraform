# ------------------------------------------------------------------------------
# AWS Variables
# ------------------------------------------------------------------------------
variable "aws_region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use"
}

variable "aws_account" {
  type        = string
  description = "The name of the AWS Account in which resources will be administered"
}

# ------------------------------------------------------------------------------
# AWS Variables - Shorthand
# ------------------------------------------------------------------------------

variable "account" {
  type        = string
  description = "Short version of the name of the AWS Account in which resources will be administered"
}

variable "region" {
  type        = string
  description = "Short version of the name of the AWS region in which resources will be administered"
}

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "The name of the environment"
}

# ------------------------------------------------------------------------------
# Common RDS Variables
# ------------------------------------------------------------------------------

variable "multi_az" {
  type        = bool
  description = "(Optional) Boolean to enable multi-az feature of RDS, subnets supplied must span multiple zones"
  default     = false
}

variable "rds_maintenance_window" {
  type        = string
  description = "A maintenance window that will allow AWS to run maintenance on underlying hosts e.g. `Mon:00:00-Mon:03:00`"
  default     = "Sat:00:00-Sat:03:00"
}

variable "rds_backup_window" {
  type        = string
  description = "A backup window that allows AWS to backup your RDS instance e.g. `03:00-06:00`"
  default     = "03:00-06:00"
}

variable "rds_log_exports" {
  type        = list(string)
  description = "A list log types to export from RDS to Cloudwatch"
  default     = []
}

variable "parameter_group_settings" {
  type        = list(any)
  description = "A list of parameters that will be set in the RDS instance parameter group"
}
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ABBYY RDS Variables
# ------------------------------------------------------------------------------
variable "abbyy_identifier" {
  type        = string
  description = "Name to give to the instances and other components created for it, will be added to naming structure e.g. mydb will become rds-mydb-<env>-001"
}

variable "abbyy_name" {
  type        = string
  description = "Name to give to the database created on the RDS Instance"
}

variable "abbyy_instance_class" {
  type        = string
  description = "The type of instance for the RDS"
  default     = "db.t3.medium"
}

variable "abbyy_rds_onpremise_access" {
  type        = list(string)
  description = "A list of CIDR ranges or IPs to allow access from"
  default     = []
}

variable "abbyy_storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not."
  default     = null
}

variable "abbyy_allocated_storage" {
  type        = number
  description = "The amount of storage in GB to launch RDS with"
}

variable "abbyy_iops" {
  type        = number
  description = "Total number of IOPS to provision, requires storage type to be set to io1, there is a minimum of 1000 IOPS and 100GB storage required for Provisioned IOPS"
  default     = null
}

variable "abbyy_backup_retention_period" {
  type        = number
  description = "The number of days to retain backups for - 0 to 35"
  default     = 7
}

variable "abbyy_rds_engine" {
  type        = string
  description = "The RDS engine type to use for this RDS instance e.g. oracle-se2 "
}

variable "abbyy_major_engine_version" {
  type        = string
  description = "The major version of the database engine type e.g. 12.1"
}

variable "abbyy_engine_version" {
  type        = string
  description = "The engine version provided by AWS RDS e.g. 12.1.0.2.v21"
}

variable "abbyy_license_model" {
  type        = string
  description = "The license model for the engine, byol or license-include: https://aws.amazon.com/rds/oracle/faqs/"
}

variable "abbyy_auto_minor_version_upgrade" {
  type        = bool
  description = "True/False value to allow AWS to apply minor version updates to RDS without approval from owner"
  default     = true
}
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# FES RDS Variables
# ------------------------------------------------------------------------------
variable "fes_identifier" {
  type        = string
  description = "Name to give to the instances and other components created for it, will be added to naming structure e.g. mydb will become rds-mydb-<env>-001"
}

variable "fes_name" {
  type        = string
  description = "Name to give to the database created on the RDS Instance"
}

variable "fes_instance_class" {
  type        = string
  description = "The type of instance for the RDS"
  default     = "db.t3.medium"
}

variable "fes_rds_onpremise_access" {
  type        = list(string)
  description = "A list of CIDR ranges or IPs to allow access from"
  default     = []
}

variable "fes_storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not."
  default     = null
}

variable "fes_allocated_storage" {
  type        = number
  description = "The amount of storage in GB to launch RDS with"
}

variable "fes_iops" {
  type        = number
  description = "Total number of IOPS to provision, requires storage type to be set to io1, there is a minimum of 1000 IOPS and 100GB storage required for Provisioned IOPS"
  default     = null
}

variable "fes_backup_retention_period" {
  type        = number
  description = "The number of days to retain backups for - 0 to 35"
  default     = 7
}

variable "fes_rds_engine" {
  type        = string
  description = "The RDS engine type to use for this RDS instance e.g. oracle-se2 "
}

variable "fes_major_engine_version" {
  type        = string
  description = "The major version of the database engine type e.g. 12.1"
}

variable "fes_engine_version" {
  type        = string
  description = "The engine version provided by AWS RDS e.g. 12.1.0.2.v21"
}

variable "fes_license_model" {
  type        = string
  description = "The license model for the engine, byol or license-include: https://aws.amazon.com/rds/oracle/faqs/"
}

variable "fes_auto_minor_version_upgrade" {
  type        = bool
  description = "True/False value to allow AWS to apply minor version updates to RDS without approval from owner"
  default     = true
}
# ------------------------------------------------------------------------------
