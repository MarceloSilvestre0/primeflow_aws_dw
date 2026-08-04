# Configura o Provedor AWS
#O que isso faz? -> Este bloco de código configura o provedor AWS para o Terraform, especificando a região onde os recursos serão criados. No caso, a região definida é "us-east-2". Isso significa que todos os recursos AWS definidos neste arquivo serão provisionados na região Leste dos EUA (Ohio).
provider "aws" {
  region = "us-east-2"
}

# Configura a Redshift VPC
#O que isso faz? -> Este bloco de código cria uma VPC (Virtual Private Cloud) na AWS com o CIDR block "
resource "aws_vpc" "redshift_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Prime Flow Redshift VPC"
  }
}

# Configura a Redshift Subnet
#O que isso faz? -> Este bloco de código cria uma Subnet dentro da VPC criada anteriormente.
#A Subnet é configurada com um CIDR block de "
resource "aws_subnet" "redshift_subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.redshift_vpc.id

  tags = {
    Name = "Prime Flow Redshift Subnet"
  }
}

# Configura um Gateway da Internet e Anexa a VPC
#O que isso faz? -> Este bloco de código cria um Internet Gateway na AWS e o anexa à VPC criada anteriormente.
#O Internet Gateway permite que a VPC se comunique com a internet, possibilitando o acesso externo aos recursos dentro da VPC, como o cluster Redshift.
resource "aws_internet_gateway" "redshift_igw" {
  vpc_id = aws_vpc.redshift_vpc.id

  tags = {
    Name = "Prime Flow Redshift Internet Gateway"
  }
}

# Configura Uma Tabela de Roteamento
#O que isso faz? -> Este bloco de código cria uma Tabela de Roteamento na AWS e define uma rota padrão (0.0.0.0/0) que aponta para o Internet Gateway.
resource "aws_route_table" "redshift_route_table" {
  vpc_id = aws_vpc.redshift_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.redshift_igw.id
  }

  tags = {
    Name = "Prime Flow Redshift Route Table"
  }
}

# Associa a Tabela de Roteamento à Subnet
resource "aws_route_table_association" "redshift_route_table_association" {
  subnet_id      = aws_subnet.redshift_subnet.id
  route_table_id = aws_route_table.redshift_route_table.id
}

# Configura Um Grupo de Segurança de Acesso ao Data Warehouse com Redshift
resource "aws_security_group" "redshift_sg" {
  name        = "redshift_sg"
  description = "Allow Redshift traffic"
  vpc_id      = aws_vpc.redshift_vpc.id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prime Flow Redshift Security Group"
  }
}

# Configura Um Grupo de Subnets Redshift Para Configuração Multi-AZ
resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "redshift-subnet-group"
  subnet_ids = [aws_subnet.redshift_subnet.id]

  tags = {
    Name = "Prime Flow Redshift Subnet Group"
  }
}

# Configura Um Cluster Redshift 
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier = "redshift-cluster"
  database_name      = "prime_flowdb"
  master_username    = "adminuser"
  master_password    = "prime_flowSecurePassw0rd!"
  node_type          = "dc2.large" #O que é o nó? -> O nó é a unidade de computação e armazenamento do cluster Redshift. O tipo de nó "dc2.large" é uma configuração
  number_of_nodes    = 1           #específica que oferece um equilíbrio entre desempenho e custo, adequada para cargas de trabalho de análise de dados.
  

  vpc_security_group_ids = [aws_security_group.redshift_sg.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name

  # O que é o skip_final_snapshot? -> O parâmetro "skip_final_snapshot" é uma configuração que determina se o Redshift deve criar um snapshot final do cluster antes de ser excluído.
  # Quando definido como "true", o Redshift não cria um snapshot final, o que significa que todos os dados no cluster serão perdidos quando ele for excluído.
  # Isso pode ser útil para ambientes de teste ou desenvolvimento onde a preservação dos dados não é necessária.
  skip_final_snapshot = true 
}
