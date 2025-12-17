# GitHub Actions Azure OIDC Troubleshooting Guide

## Problem

GitHub Actions workflow fails to authenticate to Azure with errors such as:

- `Failed to resolve tenant '***'`
- `The client '***' has no configured federated identity credentials.`
- `No subscriptions found for ***.`

## Step-by-Step Troubleshooting

### 1. Check GitHub Secrets

Ensure the following secrets are set in your repository:

- `AZURE_CLIENT_ID` (App Registration / Service Principal client ID)
- `AZURE_TENANT_ID` (Azure AD tenant ID)
- `AZURE_SUBSCRIPTION_ID` (Azure subscription ID)

> **Note:** `AZURE_CLIENT_SECRET` is NOT required for OIDC authentication.

### 2. Verify Azure/login Step in Workflow

Your workflow should use the Azure/login action with OIDC (no client secret):

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

### 3. Configure Federated Credentials in Azure

1. Go to Azure Portal → Azure Active Directory → App registrations → [Your App].
2. Select **Federated credentials** (under "Certificates & secrets").
3. Click **Add credential**.
4. Fill in:
   - **Issuer:** `https://token.actions.githubusercontent.com`
   - **Subject identifier:** `repo:Esysc/azure_aks_poc:*` (or restrict to a specific workflow)
   - **Audience:** `api://AzureADTokenExchange`
5. Save.

### 4. Assign Subscription Role to Service Principal

1. Get your Service Principal object ID:

   ```sh
   az ad sp show --id <AZURE_CLIENT_ID> --query id --output tsv
   ```

2. Assign the Contributor role at the subscription scope:

   ```sh
   az role assignment create \
     --assignee <OBJECT_ID> \
     --role Contributor \
     --scope /subscriptions/<AZURE_SUBSCRIPTION_ID>
   ```

### 5. Re-run the Workflow

After completing the above steps, re-run your GitHub Actions workflow. Azure login and Terraform should now work as expected.

## Common Errors and Fixes

- **Failed to resolve tenant '***'**
  - Check that `AZURE_TENANT_ID` is set and correct in GitHub secrets.
- **No configured federated identity credentials**
  - Add a federated credential in Azure App Registration as described above.
- **No subscriptions found for ***.**
  - Assign the required role (e.g., Contributor) to your Service Principal at the subscription scope.

---

For more details, see:

- [Azure/login GitHub Action](https://github.com/Azure/login#readme)
- [Microsoft Docs: Configure federated credentials](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation-create-trust-github?tabs=azure-portal)
