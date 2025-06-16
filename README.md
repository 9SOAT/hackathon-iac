# hackathon-iac

Este repositório contém a infraestrutura como código (IaC) para o projeto Hackathon SOAT. Utiliza Terraform para provisionamento de recursos em nuvem, incluindo API Gateway, Cognito, S3, SQS e outros serviços necessários para o ambiente de homologação.

## Estrutura do Projeto

- `infra/v1/`: Contém os módulos Terraform para os principais recursos de infraestrutura.
- `env/homolog/`: Define o ambiente de homologação, referenciando os módulos e variáveis necessários.

## Como usar

1. Instale o Terraform.
2. Configure suas credenciais de provedor de nuvem.
3. Acesse o diretório do ambiente desejado (ex: `env/homolog/`).
4. Execute os comandos Terraform padrão:
   - `terraform init`
   - `terraform plan`
   - `terraform apply`

Consulte os arquivos individuais para detalhes de configuração de cada recurso.

## Licença

Consulte o arquivo LICENSE para informações de licenciamento.