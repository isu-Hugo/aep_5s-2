# 🌍 EcoCulture API & Mobile App

O **EcoCulture** é uma plataforma sustentável desenvolvida para facilitar o descarte correto de resíduos residenciais, mapear ecopontos urbanos e engajar cidadãos por meio de um sistema de recompensas reativo (pontuação ecológica). O projeto foi construído alinhado com a **ODS 12 (Consumo e Produção Responsáveis)** e a **ODS 11 (Cidades e Comunidades Sustentáveis)**.

---

## 🛠️ Tecnologias Utilizadas

### **Back-end & Infraestrutura**
* **Java 21** com **Spring Boot**
* **Spring Data JPA** (Persistência de dados)
* **PostgreSQL** (Banco de dados relacional)
* **Docker & Docker Compose** (Containerização do banco)
* **Lombok** (Produtividade e código limpo)
* **JUnit 5 & Mockito** (Testes unitários automatizados)

### **Mobile**
* **Flutter** (Framework cross-platform)
* **http** (Comunicação assíncrona com a API)
* **url_launcher** (Integração nativa com o GPS do dispositivo)

---

## ⚙️ Como Executar o Projeto

Siga os passos abaixo na ordem correta para subir o ecossistema completo localmente.

### 📋 Pré-requisitos
Antes de começar, certifique-se de ter instalado em sua máquina:
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* [Java JDK 21 || intellij](https://www.oracle.com/java/technologies/downloads/)
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* Uma IDE de sua preferência (IntelliJ IDEA, VS Code ou Android Studio)

---

### 1️⃣ Passo 1: Subir o Banco de Dados (Docker)
Navegue até a raiz do projeto back-end (onde está localizado o arquivo `compose.yml`) e execute o comando abaixo no terminal para subir o container do PostgreSQL em segundo plano:

```bash ```
docker compose up -d

### 2️⃣ Passo 2: Executar a API Spring Boot
1. Abra o projeto back-end na sua IDE Java.
2. Aguarde o download das dependências do Maven.
3. Execute os **Testes Unitários** para garantir a integridade das regras de negócio (Clique com o botão direito na pasta de testes -> *Run All Tests* ou execute `mvn test` no terminal).
4. Execute a classe principal `ApiApplication.java`.

> 💡 **População Automática do Banco:** Na primeira inicialização, a API utiliza a classe `CommandLineRunner` configurada para criar automaticamente a estrutura de tabelas, o relacionamento `@ManyToMany`, além de inserir ecopontos e categorias de resíduos iniciais de teste caso o banco esteja vazio.

Para verificar se a API está respondendo, abra o navegador e acesse:
`http://localhost:8080/api/pontos`

### 3️⃣ Passo 3: Executar a Aplicação Mobile (Flutter)
Com o dispositivo físico (conectado via USB) ou emulador pronto:

1. Abra o projeto mobile no seu terminal ou editor.
2. Atualize o arquivo `lib/ponto_service.dart` alterando a variável `apiUrl` com o **IP local da sua máquina** na rede Wi-Fi (ex: `http://192.168.X.X:8080/api/pontos`), garantindo que o celular e o computador estejam na mesma rede.
3. Instale as dependências executando:
```bash
flutter pub get
flutter run --no-impeller
