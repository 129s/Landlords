const chalk = require('chalk');

// 时间格式化函数保持不变
function formatTime(date = new Date()) {
    const padZero = n => n.toString().padStart(2, '0');
    return `${padZero(date.getHours())}:${padZero(date.getMinutes())}:${padZero(date.getSeconds())}`;
}

const levels = {
    debug: {
        color: chalk.hex('#8E8E8E'), // 灰色
        header: chalk.hex('#8E8E8E').bold('[DEBUG]')
    },
    info: {
        color: chalk.hex('#00FF00'), // 亮绿色
        header: chalk.hex('#00FF00').bold('[INFO] ')
    },
    warn: {
        color: chalk.hex('#FFA500'), // 橙色
        header: chalk.hex('#FFA500').bold('[WARN] ')
    },
    error: {
        color: chalk.hex('#FF0000'), // 亮红色
        header: chalk.hex('#FF0000').bold('[ERROR]')
    },
};

const logger = {
    debug: (message, ...args) => log('debug', message, args),
    info: (message, ...args) => log('info', message, args),
    warn: (message, ...args) => log('warn', message, args),
    error: (message, ...args) => log('error', message, args),
};

function log(level, message, args) {
    const timestamp = chalk.hex('#808080')(formatTime()); // 灰色时间戳
    const { color, header } = levels[level];

    // 黄色参数
    const coloredArgs = args.map(arg => chalk.hex('#FFFF00')(arg));
    const formattedMessage = message.split('%s').reduce((acc, part, i) =>
        acc + part + (coloredArgs[i] || ''), ''
    );

    console.log(
        `${timestamp} ${header} ${color(formattedMessage)}`
    );
}

module.exports = logger;