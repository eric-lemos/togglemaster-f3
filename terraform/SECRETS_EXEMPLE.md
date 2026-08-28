# Senhas do RDS via variável de ambiente

Não é possível usar AWS Secrets Manager neste ambiente (AWS Academy `LabRole` sem permissão `secretsmanager:CreateSecret`). A senha deve ser passada via `TF_VAR_rds_instance_passwords` no terminal, sem gravar em arquivo.

## Uso direto

```bash
export TF_VAR_rds_instance_passwords='{"flags":"REPLACE_WITH_A_STRONG_PASSWORD"}'

# RDS does not allow '/', '@', '"' or spaces in the password.

terraform plan
terraform apply
```

## Alternativa: variável intermediária

```bash
RDS_PASSWORDS='{"flags":"REPLACE_WITH_A_STRONG_PASSWORD"}'
export TF_VAR_rds_instance_passwords="$RDS_PASSWORDS"

terraform plan
terraform apply
```
