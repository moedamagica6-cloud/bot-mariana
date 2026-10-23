const { Client, GatewayIntentBits, EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle, ChannelType } = require('discord.js');
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

// 1️⃣ Webhook para receber as notificações do MacroDroid
app.post('/webhook-pix', (req, res) => {
    const { titulo, texto } = req.body;
    console.log(`[PIX RECEBIDO] Título: ${titulo} \vert{} Texto:${texto}`);

    ultimosPix.unshift({ titulo, texto, timestamp: Date.now() });
    if (ultimosPix.length > 20) ultimosPix.pop();

    res.status(200).send({ status: 'recebido com sucesso' });
});

client.once('ready', () => {
    console.log(`✨ Mariana - Suporte online e monitorando novas salas!`);
});

// 🤖 2. MENSAGEM AUTOMÁTICA QUANDO O CANAL DE APOSTA É CRIADO
client.on('channelCreate', async (channel) => {
    // Verifica se é um canal de texto e se o nome contém "aposta" ou "ticket"
    if (channel.type === ChannelType.GuildText && (channel.name.includes('aposta') || channel.name.includes('ticket'))) {
        
        // Aguarda 1.5 segundos para garantir que o canal foi totalmente carregado no servidor
        setTimeout(async () => {
            const chavePix = "123.234.456.09"; // Coloque a sua chave PIX real aqui
            const titular = "ALAN FERREIRA DOS SANTOS SILVA";

            const embedBoasVindas = new EmbedBuilder()
                .setTitle('👋 Olá! Sou a Mariana do Suporte')
                .setDescription(`Seja bem-vindo(a) à sua sala de apostas! Estou aqui para liberar o seu bilhete de forma rápida e automática assim que o pagamento for concluído.`)
                .addFields(
                    { 
                        name: '💳 Dados para Pagamento PIX', 
                        value: `👤 **Titular:** ${titular}\n🔑 **Chave PIX:** \`${chavePix}\`` 
                    },
                    { 
                        name: '📌 Como confirmar seu pagamento?', 
                        value: 'Após fazer o PIX pelo app do seu banco, digite nesta sala:\n👉 **`Pg [Seu Nome e Sobrenome]`**\n\n*Exemplo:* `Pg Alan Ferreira`' 
                    }
                )
                .setImage('https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=' + encodeURIComponent(chavePix))
                .setColor('#E74C3C')
                .setFooter({ text: 'Mariana - Atendimento & Validação Automática' })
                .setTimestamp();

            // Botões interativos
            const botoes = new ActionRowBuilder().addComponents(
                new ButtonBuilder()
                    .setCustomId('copiar_pix')
                    .setLabel('📋 Copiar Chave PIX')
                    .setStyle(ButtonStyle.Success),
                new ButtonBuilder()
                    .setCustomId('duvida_pg')
                    .setLabel('❓ Como Validar?')
                    .setStyle(ButtonStyle.Secondary)
            );

            try {
                await channel.send({ embeds: [embedBoasVindas], components: [botoes] });
            } catch (error) {
                console.error("Erro ao enviar mensagem automática no canal:", error);
            }
        }, 1500);
    }
});

// 🔍 3. VALIDAÇÃO DO COMANDO "Pg [Nome]"
client.on('messageCreate', async (message) => {
    if (message.author.bot) return;

    const args = message.content.trim().split(' ');
    const comando = args[0].toLowerCase();

    if (comando === 'pg') {
        const nomePesquisado = args.slice(1).join(' ').toLowerCase();

        if (!nomePesquisado) {
            return message.reply('❌ Por favor, informe o seu Nome e Sobrenome cadastrados no Pix.\n*Exemplo:* `Pg Alan Ferreira`');
        }

        // Procura nos Pix recebidos recentemente pelo MacroDroid
        const pixEncontrado = ultimosPix.find(p => 
            (p.titulo && p.titulo.toLowerCase().includes(nomePesquisado)) ||
            (p.texto && p.texto.toLowerCase().includes(nomePesquisado))
        );

        if (pixEncontrado) {
            const embedSucesso = new EmbedBuilder()
                .setTitle('✅ PAGAMENTO CONFIRMADO COM SUCESSO!')
                .setDescription(`O Pix de **${nomePesquisado.toUpperCase()}** foi identificado no sistema!`)
                .addFields(
                    { name: '📄 Detalhes da Transação', value: `\`\`\`${pixEncontrado.texto}\`\`\`` },
                    { name: '🎲 Status da Aposta', value: '🟢 **BILHETE CONFIRMADO E REGISTRADO! BOA SORTE!**' }
                )
                .setColor('#2ECC71')
                .setTimestamp();

            await message.reply({ embeds: [embedSucesso] });
        } else {
            await message.reply(`❌ Nenhum Pix recente no nome **"${nomePesquisado}"** foi encontrado até o momento.\n\n💡 *Aguarde alguns segundos se acabou de pagar ou verifique se o nome digitado é exatamente o do comprovante.*`);
        }
    }
});

// 🔘 4. RESPOSTA DOS BOTÕES INTERATIVOS
client.on('interactionCreate', async (interaction) => {
    if (!interaction.isButton()) return;

    if (interaction.customId === 'copiar_pix') {
        await interaction.reply({ content: '🔑 **Chave PIX:** `123.234.456.09`', ephemeral: true });
    }

    if (interaction.customId === 'duvida_pg') {
        await interaction.reply({ 
            content: '📌 **Como funciona a validação?**\n1️⃣ Faça o PIX no app do seu banco.\n2️⃣ Assim que o comprovante sair, envie nesta sala: `Pg [Nome do Pix]`.\n3️⃣ Eu verifico as notificações em tempo real e libero a sua aposta na hora!', 
            ephemeral: true 
        });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Servidor de Webhook rodando na porta ${PORT}`);
});

// 🔑 TOKEN DO BOT CONFIGURADO
client.login('MTU2MjU4MzAxMjE3OTQ0NzgzOQ.GZUYy-.NYPzQPTgroyp4MtFRdSuLiSH6eorxZeWr84xF4');

