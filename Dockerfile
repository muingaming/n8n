FROM n8nio/n8n:latest

ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=https
ENV N8N_SECURE_COOKIE=true

EXPOSE 5678

CMD ["sh", "-c", "n8n start --port $PORT"]
