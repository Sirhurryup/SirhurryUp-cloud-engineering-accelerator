# AWS CLI + Terraform Authentication — Quick Reference

**Project:** SirhurryUp Cloud Engineering Accelerator  
**Computers:** Intel iMac (x86_64) and Apple Silicon MacBook Pro (arm64)  
**Goal:** Authenticate to my AWS sandbox securely and know exactly which account Terraform will use.

> **Safety rule:** I never paste or commit AWS access keys, secret access keys, session tokens, or files from `~/.aws/`.

## 1. Confirm my tools

```bash
aws --version
terraform version
command -v aws
command -v terraform
```

- `--version` tells me whether a tool is installed and working.
- `command -v` shows the executable selected by my shell's `PATH`.
- On an Intel iMac, `/usr/local/bin` is a common installation location. The exact path can differ.

## 2. See my AWS profiles (without exposing secrets)

```bash
aws configure list-profiles
```

An AWS **profile** is a named set of authentication and configuration settings. My expected profile name is `sandbox`, but I verify it exists on each computer.

## 3. Verify my AWS identity before doing anything

```bash
aws sts get-caller-identity --profile sandbox
```

I inspect the returned **Account** and **Arn**. I proceed only if they identify my intended sandbox account and role. `sts` means **Security Token Service**.

**Do not assume a profile is valid just because it is listed.** Profiles can exist while their credentials have expired.

## 4. Tell Terraform which profile to use

For a Terraform configuration that does not already choose a profile, I can select the profile for the current terminal session:

```bash
export AWS_PROFILE=sandbox
aws sts get-caller-identity
```

`export` sets an **environment variable** inherited by Terraform and other commands started from this shell. I verify the identity again before proceeding.

**Important:** An explicit profile in the Terraform AWS provider, other environment credentials, or an assumed-role configuration can change which identity is used. I inspect my provider configuration rather than assuming `AWS_PROFILE` always wins.

## 5. Terraform workflow (inside the project directory)

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
```

- `init` prepares the working directory, providers, and backend.
- `fmt -check` checks formatting without changing files.
- `validate` checks configuration structure; it does **not** prove AWS access or application health.
- `plan` previews proposed infrastructure changes. I review the resource list, account context, and cost implications before applying.

Only after reviewing the plan and confirming the intended account:

```bash
terraform apply
```

For disposable sandbox labs, after capturing evidence and confirming resources are no longer needed:

```bash
terraform destroy
```

**Caution:** `destroy` removes resources managed by the current Terraform state. I inspect its plan before approving.

## 6. When credentials expire

**Symptoms:** `ExpiredToken`, `InvalidClientTokenId`, `AccessDenied`, or failed STS authentication. These errors have different causes; I read the exact message.

1. Run `aws sts get-caller-identity --profile sandbox` to check the profile.
2. Refresh the login using the authentication method that profile actually uses:
   - **IAM Identity Center / SSO profile:** `aws sso login --profile sandbox`
   - **Assume-role profile:** refresh the source credentials/session required by its `source_profile` or credential provider.
3. Run `aws sts get-caller-identity --profile sandbox` again.
4. Re-run `terraform plan` before applying changes.

I do **not** create permanent IAM access keys merely to avoid a short-lived login.

## 7. GitHub is separate from AWS

```bash
git remote -v
git status --short
```

- GitHub authentication authorizes `git push`; AWS authentication authorizes cloud API calls.
- If my Git remote uses `git@github.com:...`, it uses SSH authentication. A GitHub personal access token is not required for that SSH workflow.
- GitHub CLI (`gh`) is optional, not required for ordinary SSH-based Git pushes.
- For future GitHub Actions deployments, I should evaluate **OIDC** (OpenID Connect) to obtain temporary AWS credentials without storing long-lived AWS secrets in GitHub.

## 8. My pre-deployment mental checklist

- [ ] I am on the intended computer and repository branch.
- [ ] `aws sts get-caller-identity --profile sandbox` shows the correct account and role.
- [ ] Terraform is using the intended AWS identity and region.
- [ ] I understand the `terraform plan` changes and cost drivers.
- [ ] I have a test and cleanup plan.
- [ ] I will record evidence as I work, not reconstruct it later.

## Key concepts to remember

| Term | Meaning |
|---|---|
| `PATH` | Shell search directories used to find commands |
| AWS CLI profile | Named AWS configuration and credential-selection settings |
| IAM role | AWS identity that can be assumed for temporary permissions |
| STS | AWS Security Token Service; supports temporary credentials and identity checks |
| Least privilege | Grant only the permissions needed for a task |
| Terraform provider | Plugin that lets Terraform interact with an API such as AWS |
| Terraform state | Record Terraform uses to map its resources to real infrastructure |
| OIDC | Federated identity mechanism often used for GitHub Actions → AWS access |

## Independent recall — check myself

**Q1.** What command tells me which AWS account my `sandbox` profile is using?  
**A1.** `aws sts get-caller-identity --profile sandbox`. I check `Account` and `Arn`, not just whether the command succeeds.

**Q2.** Does `terraform validate` prove my web server is working?  
**A2.** No. It checks Terraform configuration validity. I still need deployment, connectivity, application, and recovery tests.

**Q3.** Do I need a GitHub token when I push using an SSH remote?  
**A3.** No. SSH uses my configured SSH key. GitHub tokens are a different authentication mechanism.

**Q4.** Why are temporary credentials preferable to long-lived IAM user keys?  
**A4.** They expire, reducing the exposure window if compromised, and fit role-based access patterns.

**Q5.** What should I do before `terraform apply`?  
**A5.** Verify my AWS identity and region, review `terraform plan`, understand costs and security changes, and know how I will test and clean up.

---

## My Daily AWS + Terraform Workflow

### Authenticate
aws login --profile sirhurryup-admin

### Select an AWS account
export AWS_PROFILE=sandbox

### Verify my identity
aws sts get-caller-identity

### Switch accounts
export AWS_PROFILE=managed-websites
aws sts get-caller-identity

### Before running Terraform
1. Verify the AWS account and IAM role.
2. Confirm I am in the correct project directory.
3. Run terraform plan and inspect the proposed changes.
4. Run terraform apply only when the plan is correct.

### Key Concepts
- AWS_PROFILE selects my AWS CLI profile.
- source_profile supplies credentials for role assumption.
- AWS STS issues temporary credentials.
- Terraform can use my selected AWS profile automatically.
- Switching profiles does not switch Terraform state.
- I do not need to manually save assumed-role credentials.

**Next lab:** Inspect the actual `sandbox` profile on both Macs before deciding whether to configure a dedicated Terraform role. This sheet describes a safe workflow; it does not claim that authentication has already been configured or tested on either computer.

*Pace and purpose. BTM — Break the Mold.*
