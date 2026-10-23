const { Client, GatewayIntentBits, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle } = require('discord.js');
const express = require('express');

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent
    ]
});

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

client.on('ready', () => {
    console.log(`Bot online como ${client.user.tag}!`);
});

// Podes colocar aqui o teu token real ou usar o fictício para testar
client.login("MTU2MjU4MzAxMjE3OTQ0NzgzOQ.GtAgRR.ovkj1Qm3C9z53G8lx9b6APyQzO_RCLvTSguavA");

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor web rodando na porta ${PORT}`);
});

