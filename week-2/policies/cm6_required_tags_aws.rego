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

# TODO (your build): deny any taggable resource that is missing one or more
# required tags. With provider default_tags enabled, the merged set is in
# values.tags_all; fall back to values.tags. Read resources from
# input.planned_values.root_module.resources (and child_modules if you nest).
#
# The stub keeps `deny` defined (empty) so the test file loads. Replace it.
deny contains msg if {
	false
	msg := "todo"
}
