# ONIX AI Connect

Plataforma SaaS para atendimento empresarial com IA e WhatsApp. **Estado atual: MVP demonstrativo, não pronto para operação comercial.**

## O que funciona nesta etapa
- Interface responsiva em português e identidade visual ONIX.
- Dashboard demonstrativo; cadastro de empresas e configuração de assistentes armazenados **somente no localStorage do navegador**.
- Endpoint `GET /api/webhooks/whatsapp` para verificação da Meta, quando `META_VERIFY_TOKEN` for definido.
- Endpoint `POST /api/webhooks/whatsapp` verifica assinatura HMAC SHA-256 com `META_APP_SECRET`; **não processa nem persiste mensagens**.
- Rascunho de esquema PostgreSQL para Supabase em `supabase/schema.sql` com RLS habilitado e políticas de leitura por associação.

## Rodar localmente
Requisitos: Node.js 20+ e npm.

```bash
npm install
cp .env.example .env.local
npm run dev
```

Abra http://localhost:3000.

## Publicar na Vercel
1. Em https://vercel.com/new, selecione **Import Git Repository** e escolha `albersmkt/ONIX-AI-Connect`.
2. Framework: Next.js. Root Directory: `./`. Build: `npm run build`.
3. Configure as variáveis de ambiente necessárias em Project Settings > Environment Variables.
4. Publique e valide a URL `*.vercel.app` fornecida pelo projeto. Domínio próprio pode ser configurado depois em Settings > Domains.

Nenhuma chave privada deve ser adicionada a este repositório. A configuração do ambiente e DNS é externa ao código.

## Para produção (pendências indispensáveis)
- Implementar autenticação Supabase, onboarding de organizações, criação segura de membership, controle de acesso e políticas de escrita com isolamento real de tenant.
- Substituir armazenamento local por acesso autenticado ao banco e validar regras de RLS.
- Mapear cada `phone_number_id` da Meta à organização correta e armazenar credenciais com proteção apropriada.
- Criar fila durável/idempotente para webhooks, persistência de mensagens, envio via Cloud API, retries, rastreamento e transferência para humano.
- Implementar RAG com documentos por organização, regras de consentimento, retenção e LGPD.
- Criar planos, limites de consumo, cobrança, auditoria, observabilidade e testes automatizados.
- Conferir termos comerciais e políticas vigentes da Meta antes de conectar clientes.

## Endpoints
- `GET /api/webhooks/whatsapp?hub.mode=subscribe&hub.verify_token=...&hub.challenge=...` verifica challenge Meta.
- `POST /api/webhooks/whatsapp` autentica assinatura e devolve ACK; **não habilite webhook de mensagens reais até concluir a ingestão durável**.

## Nota importante
Este MVP não autentica usuários, não atende clientes reais e não envia mensagens pelo WhatsApp. A experiência é protótipo de interface, apesar de o endpoint de autenticação de webhook estar implementado.
