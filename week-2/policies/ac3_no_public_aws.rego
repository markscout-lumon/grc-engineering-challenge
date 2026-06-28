# METADATA
# title: AC-3 - Access Enforcement (AWS S3 public access block)
# description: Every aws_s3_bucket must have a public access block with all four flags true.
# custom:
#   control_id: AC-3
#   framework: nist-800-53
#   severity: critical
#   remediation: Add aws_s3_bucket_public_access_block referencing the bucket, all four flags true.
package compliance.ac3_aws

import rego.v1

# YOUR BUILD: deny any aws_s3_bucket that does not have a matching
# aws_s3_bucket_public_access_block with block_public_acls, block_public_policy,
# ignore_public_acls, and restrict_public_buckets all set to true.
#
# Match the bucket by reference the way sc28_encryption_aws.rego does, in
# input.configuration.root_module.resources[].expressions.bucket.references.
# Read the four flag values from input.planned_values.root_module.resources[]
# where .address is the public access block's address.
#
# Deny any bucket that has no public access block .
deny contains msg if {
	some bucket in input.configuration.root_module.resources
	bucket.type == "aws_s3_bucket"

	addr := sprintf("aws_s3_bucket.%s", [bucket.name])

	not bucket_public_access_blocked(addr)

	msg := sprintf("AC-3: %s public access block not configured correctly.", [addr])
}

# True if public access blocked on all four flags.
bucket_public_access_blocked(addr) if {
	# Step 1: find a PAB in configuration that references this bucket
	some pab in input.configuration.root_module.resources
	pab.type == "aws_s3_bucket_public_access_block"                         
	some ref in pab.expressions.bucket.references
	startswith(ref, addr)
	pab_addr := sprintf("aws_s3_bucket_public_access_block.%s", [pab.name])

	# Step 2: find that same PAB in planned_values and read its flags
	some pv in input.planned_values.root_module.resources
	pv.address == pab_addr
	v := pv.values

	# Step 3: all four flags must be true
	v.block_public_acls == true
	v.block_public_policy == true
	v.ignore_public_acls == true
	v.restrict_public_buckets == true
}
