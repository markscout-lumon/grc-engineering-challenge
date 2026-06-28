# METADATA
# title: CM-6 - Configuration Settings (AWS required tags)
# description: Taggable resources must carry the four required compliance tags.
# custom:
#   control_id: CM-6
#   framework: nist-800-53
#   severity: medium
#   remediation: Add the missing tags or rely on provider default_tags.
package compliance.cm6_aws

import rego.v1

required := {"Project", "Environment", "ManagedBy", "ComplianceScope"}

# YOUR BUILD: deny any taggable resource that is missing one or more
# required tags. With provider default_tags enabled, the merged set is in
# values.tags_all; fall back to values.tags. Read resources from
# input.planned_values.root_module.resources (and child_modules if you nest).
#
deny contains msg if {
	some resource in input.planned_values.root_module.resources
	tags := resource.values.tags_all

	some required_tag in required
	not tags[required_tag]   

	msg := sprintf("CM-6: %s missing required tag %s", [resource.address, required_tag])   # ← blank 2
}
