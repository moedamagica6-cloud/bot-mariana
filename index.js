const { Client, GatewayIntentBits } = require('discord.js');
const express = require('express');

const app = express();
app.use(express.json());

let ultimosPix = [];

app.post('/webhook-pix', (req, res) => {
    const { titulo, texto } = req.body;
    console.log(`PIX RECEBIDO| Título: ${titulo} | Texto: ${texto}`);
    ultimosPix.unshift({ titulo, texto, timestamp: Date.now() });
    if (ultimosPix.length > 20) ultimosPix.pop();
    res.status(200).send('Recebido com sucesso');
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
    console.log(`Servidor web rodando na porta ${PORT}`);
});

// Inicialização do Discord com diagnóstico de erros
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.on('ready', () => {
    console.log(`SUCESSO: Bot online como ${client.user.tag}! 🎉`);
});

client.on('error', (error) => {
    console.error('ERRO NO CLIENTE DISCORD:', error);
});

// Validação e login seguro
if (!process.env.DISCORD_TOKEN) {
    console.error('ERRO CRÍTICO: A variável DISCORD_TOKEN não está definida no Render!');
} else {
    console.log('A tentar efetuar login no Discord...');
    client.login(process.env.DISCORD_TOKEN).catch(err => {
        console.error('FALHA AO FAZER LOGIN NO DISCORD:', err);
    });
}

