# Plataforma Web para Monitoramento Passivo e Avaliação de Segurança de Redes em Ambiente Windows

## Visão Geral

Esta aplicação consiste em uma **plataforma web local** desenvolvida para
**monitoramento passivo de redes Wi-Fi em ambiente Windows**, com foco na
coleta de informações expostas pelo sistema operacional, análise
configuracional e **avaliação básica da postura de segurança da rede**.

O projeto integra conhecimentos de **redes de computadores**, **segurança da informação**,
**programação web** e **automação**, utilizando PHP, PowerShell e tecnologias web
tradicionais, respeitando as limitações técnicas e de segurança do sistema operacional Windows.

---

## Tecnologias Utilizadas

- **Frontend:** HTML5, CSS3  
- **Backend:** PHP  
- **Sensor:** PowerShell (Windows)  
- **Comunicação:** HTTP (localhost)  
- **Sistema Operacional:** Windows 10 / Windows 11  

---

## Arquitetura da Aplicação

A aplicação segue um modelo **cliente-servidor local**, composto por:

- Interface web em PHP responsável por disponibilizar o sensor PowerShell
- Sensor PowerShell executado localmente no sistema Windows do usuário
- Envio de dados via HTTP POST para o backend
- Backend responsável por validar e persistir os dados em arquivos JSON

Todo o processamento ocorre **localmente**, não havendo envio de dados para servidores externos.

---

## Coleta de Dados

A coleta de informações é realizada de forma **estritamente passiva**, utilizando
comandos nativos do Windows e informações já disponíveis no sistema operacional.

### Coleta de redes Wi-Fi

A detecção de redes Wi-Fi utiliza o comando: netsh wlan show networks mode=bssid

Para mitigar limitações de cache de drivers Wi-Fi, o sensor executa
**múltiplas tentativas sequenciais de varredura**, consolidando os resultados
em uma única estrutura de dados.

As informações coletadas incluem, quando disponíveis:

- SSID (nome da rede)
- BSSID (endereço MAC do ponto de acesso)
- Canal de operação
- Intensidade do sinal (RSSI em percentual)
- Tipo de autenticação (ex: WPA2-Personal)
- Tipo de criptografia (ex: CCMP)
- Tipo de rede (Infraestrutura)
- Timestamp da coleta
- Identificação do host (hostname)

### Descoberta passiva de hosts na rede conectada

Adicionalmente, o sensor realiza **descoberta passiva de dispositivos** 
presentes na rede à qual o host está conectado, utilizando o **cache ARP** do sistema: arp -a


As informações coletadas incluem:

- Endereço IP
- Endereço MAC
- Tipo de entrada (dynamic/static)

Nenhuma varredura ativa, flood ou injeção de pacotes é realizada.

---

## Diagnóstico de Confiabilidade

O sensor gera automaticamente um **bloco de diagnóstico**, indicando:

- Número de tentativas de scan realizadas
- Quantidade total de redes detectadas
- Status da coleta (ex: limitação de driver ou múltiplas redes detectadas)

Esse diagnóstico tem como objetivo **contextualizar os dados coletados** e
explicitar limitações técnicas do hardware ou do driver Wi-Fi.

---

## Execução do Sensor

### Passos para execução

1. Acesse a interface web da aplicação: http://localhost/WebRedes/www

2. Faça o download do sensor PowerShell (`wifi_sensor.ps1`) ou (`wifi_sensor_ingles.ps1`).

3. Abra o PowerShell no Windows.

4. Navegue até o diretório onde o script foi salvo.

5. Execute o comando: powershell -ExecutionPolicy Bypass -File wifi_sensor.ps1

6. O arquivo `wifi_scan.json` será gerado localmente e os dados serão enviados
automaticamente para o backend da aplicação.

---

## Armazenamento dos Dados

Os dados coletados são armazenados no diretório: /www/logs/


Cada execução do sensor gera um novo arquivo JSON com timestamp,
permitindo **análise histórica**, comparação de ambientes e auditoria técnica.

---

## Limitações Técnicas

- O projeto **não utiliza modo monitor**
- Não realiza captura de pacotes ou payload de tráfego
- Não executa ataques de rede ou testes intrusivos
- A visibilidade de redes Wi-Fi depende das limitações do driver e do adaptador
- Redes ocultas (SSID hidden) podem não ser detectadas
- O escopo é restrito a ambiente local (localhost)
- Compatível apenas com sistemas Windows

Essas limitações são inerentes ao ambiente Windows e fazem parte do escopo do projeto.

---

## Objetivo Acadêmico

Este projeto foi desenvolvido com o objetivo de consolidar conhecimentos em:

- Monitoramento passivo de redes em ambiente Windows
- Integração entre PowerShell e aplicações web
- Coleta, normalização e persistência de dados de rede
- Avaliação básica de postura de segurança
- Documentação técnica e diagnóstico de confiabilidade
- Desenvolvimento de ferramentas de apoio ao suporte e à segurança de redes

---

Se quiser, o próximo passo natural para a documentação seria adicionar:

- **Modelo de relatório técnico**
- **Critérios de classificação de risco**
- **Exemplos de análise dos dados coletados**
- **Evoluções futuras do projeto**

