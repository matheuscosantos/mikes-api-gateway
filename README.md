# Configuração do AWS API Gateway com Terraform

Esta configuração do Terraform cria um API Gateway com várias rotas e integrações, juntamente com os autorizadores e validadores necessários.

[Desenho da arquitetura](https://drive.google.com/file/d/12gofNmXk8W2QnhxiFWCI4OmvVH6Vsgun/view?usp=drive_link)

## Pré-requisitos

- Terraform instalado em sua máquina
- Credenciais da AWS configuradas em sua máquina

## Uso

1. Clone este repositório.
2. Certifique-se de que suas credenciais da AWS estejam configuradas corretamente.
3. Navegue até o diretório contendo o arquivo `gateway.tf`.
4. Execute `terraform init` para inicializar a configuração do Terraform.
5. Execute `terraform plan` para ver as alterações planejadas.
6. Execute `terraform apply` para aplicar as alterações e criar o API Gateway.

## Rotas

- **POST /auth:** Rota para autenticação.
- **POST /customers:** Criar um novo cliente.
- **GET /customers/{id}:** Obter um cliente por ID.
- **DELETE /customers/{id}:** Excluir um cliente por ID.
- **POST /orders:** Criar um novo pedido.
- **GET /orders/{id}:** Obter um pedido por ID.
- **GET /orders:** Obter todos os pedidos.
- **POST /products:** Criar um novo produto.
- **GET /products/category:** Obter produtos por categoria.
- **GET /products/{id}:** Obter um produto por ID.
- **PUT /products/{id}:** Atualizar um produto por ID.
- **DELETE /products/{id}:** Excluir um produto por ID.
- **POST /production-history:** Adicionar status de produção.

## Recursos

- **Função AWS Lambda:** `mikes_lambda_authorizer` - Usada para autorização.
- **API Gateway:** `mikes_api_gateway` - Recurso principal do API Gateway.
- **Autorizador:** `cognito_authorizer` - Autorizador do pool de usuários do Cognito.
- **Implantação:** `mikes-api-gateway-deployment` - Implantação para o API Gateway.
- **Validador de Requisição:** `validator` - Validador de requisição para o API Gateway.

## Observação

- Certifique-se de substituir o URI nos recursos `aws_api_gateway_integration` com o seu próprio endpoint de serviço.
- Certifique-se de configurar o bloco `provider` em `gateway.tf` com a região AWS correta.
