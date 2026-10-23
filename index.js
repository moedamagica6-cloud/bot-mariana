const { Client, GatewayIntentBits, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor web rodando na porta ${PORT}`);
});

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

client.on('ready', () => {
    console.log(`Bot online como ${client.user.tag}! 🎉`);
});

// Faz o login imediatamente usando a variável de ambiente segura
client.login(process.env.DISCORD_TOKEN);

