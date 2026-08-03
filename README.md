# grc-engineering-challenge
6 week challenge in the GRC engineering Patreon community

# Week 1: Your First Compliant Resource.
Write Terraform for a single cloud storage bucket that enforces encryption, blocks public access, keeps versions, logs access, and tags itself. Capture the proof as machine-readable JSON. No screenshots.

# Week 2: Make the Rules Executable. 
Write policy as code that reads your Terraform plan and proves the controls from week 1 are actually in place. Real policies, with unit tests for both the passing case and the failing case.

# Week 3: Build the Gate. 
Wire those policies into a CI pipeline that runs on every pull request. Open one PR that passes and watch it go green. Open one that breaks a control and watch the gate block it.

# Week 4: Evidence You Can Trust. 
Extend the pipeline to capture evidence on every run and sign it, keyless, so anyone can verify it was produced by your pipeline and has not been touched since. This is the chain of custody.

# Week 5: Turn On the Cameras. 
Stand up native cloud monitoring controls, capture a snapshot of the findings as evidence, then tear it all down. This is the one week that touches real infrastructure, and you will spend pennies.

# Week 6: Speak the Auditor's Language. 
Map everything you built to NIST 800-53 controls in OSCAL, the machine-readable format auditors are moving toward, with evidence links that point at the signed bundles your pipeline produced. Then write the portfolio case study that ties the whole thing together.
