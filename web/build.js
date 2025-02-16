/*
 * usage: `node build.js`
 * This script is for generating `mediaplayer.js`
 * To run this script, you need to have `Node.js` and `git` installed
 * Then run `npm install` for the first time
 */
'use strict';
(async () => {
	const fs = require('fs'),
		path = require('path'),
		terser = require('terser'),
		child_process = require('child_process'),
		hlsres = await fetch('https://github.com/video-dev/hls.js/releases/latest', {
			method: 'HEAD',
			redirect: 'manual'
		}),
		hlsver = hlsres.headers.get('location').match(/v\d+\.\d+\.\d+$/),
		dashres = await fetch('https://github.com/Dash-Industry-Forum/dash.js/releases/latest', {
			method: 'HEAD',
			redirect: 'manual'
		}),
		dashver = dashres.headers.get('location').match(/v\d+\.\d+\.\d+$/);
	hlsres.arrayBuffer();
	if (!hlsver || !dashver) {
		console.error('Failed to get the latest version');
	} else {
		console.log(`Initializing hls.js...`);
		const hlsjsDir = path.join(__dirname, 'hls.js');
		if (fs.existsSync(hlsjsDir)) {
			child_process.execSync(`git reset --hard`, { cwd: hlsjsDir });
			child_process.execSync(`git checkout master`, { cwd: hlsjsDir });
			child_process.execSync(`git pull`, { cwd: hlsjsDir });
		} else {
			child_process.execSync(`git clone https://github.com/video-dev/hls.js.git`);
		}
		child_process.execSync(`git checkout tags/${hlsver[0]}`, { cwd: hlsjsDir });
		child_process.execSync(`npm update`, { cwd: hlsjsDir });
		const cfgFile = path.join(hlsjsDir, 'build-config.js'),
			cfg = await fs.promises.readFile(cfgFile, 'utf8');
		await fs.promises.writeFile(cfgFile, cfg.replace(/babelPresetEnvTargets = \{[^}]+}/, `babelPresetEnvTargets = {
			chrome: '84',
			firefox: '90',
			safari: '15',
			samsung: '14'
		}`));

		console.log(`Building hls.js...`);
		child_process.execSync(`npm run build`, { cwd: hlsjsDir });
		const hlsjs = (await fs.promises.readFile(path.join(hlsjsDir, 'dist', 'hls.js'), 'utf8')).replace(/\(function \(global, factory\) \{.+?'use strict';/s, '').replace(/}\)\);\s+}\)\(false\);\s+\/\/# sourceMappingURL=hls\.js\.map/, '})(false)').replace(/var exports=\{};var module=\{exports:exports};function define\(f\)\{f\(\)};define\.amd=true/, `'use strict'`).replace(/var canCreateWorker =.+?if (canCreateWorker) {|if \(config.workerPath\) \{.+?} else \{/s, 'if (true) {');
		//using apple's hls.js for now
		/*const req = await fetch('https://developer.apple.com/videos/scripts/hls/hls.min.js');
		const hlsjs = (await req.text()).replace(/\/\*[^\*]+\*\/\n!/, '(').replace(/this;var [^"]+"use strict"/, 'globalThis').replace(/var exports=\{};var module=\{exports:exports};function define\(f\)\{f\(\)};define\.amd=true/, `'use strict'`).replace(/,"object"==typeof exports&&"undefined"!=typeof module\?module\.exports=.+?\(\)}\(!1\);\n?$/, ')()');
		//await fs.promises.writeFile(path.join(__dirname, 'mediaplayer.js'), hlsjs);*/
		//process.exit(0);

		console.log(`Initializing dash.js...`);
		const dashjsDir = path.join(__dirname, 'dash.js');
		if (fs.existsSync(dashjsDir)) {
			child_process.execSync(`git reset --hard`, { cwd: dashjsDir });
			child_process.execSync(`git checkout master`, { cwd: dashjsDir });
			child_process.execSync(`git pull`, { cwd: dashjsDir });
		} else {
			child_process.execSync(`git clone https://github.com/Dash-Industry-Forum/dash.js.git`);
		}
		child_process.execSync(`git checkout tags/${dashver[0]}`, { cwd: dashjsDir });
		child_process.execSync(`npm update`, { cwd: dashjsDir });
		const playerjsFile = path.join(dashjsDir, 'src', 'streaming', 'MediaPlayer.js');
		const playerjs = await fs.promises.readFile(playerjsFile, 'utf8');
		await fs.promises.writeFile(
			playerjsFile,
			`import MssHandler from '../mss/MssHandler.js';import Protection from './protection/Protection.js';` +
			playerjs.replace(/dashjs\./g, '').replace(/metricsReportingController,|offlineController,|getOfflineController,|if \(metricsReportingController\) \{[^}]+}|if \(offlineController\) \{[^}]+}|offlineController = null;|metricsReportingController = null;|_detectOffline\(\);|_detectMetricsReporting\(\);| \|\| typeof dashjs === 'undefined'|if \(typeof dashjs === 'undefined'\) {[^}]+}/g, '')
		);
		await fs.promises.writeFile(path.join(dashjsDir, 'index_mediaplayerOnly.js'), `
			import FactoryMaker from './src/core/FactoryMaker.js';
			import MediaPlayer from './src/streaming/MediaPlayer.js';
			const dashjs = MediaPlayer().create;
			dashjs.events = MediaPlayer.events;
			dashjs.FactoryMaker = FactoryMaker;
			export default dashjs;
		`);
		await fs.promises.writeFile(path.join(dashjsDir, '.browserslistrc'), `chrome >= 84\nfirefox >= 90\nsafari >= 15\nsamsung >= 14`);
		const protectionjsFile = path.join(dashjsDir, 'src', 'streaming', 'protection', 'Protection.js');
		const protectionjs = await fs.promises.readFile(protectionjsFile, 'utf8');
		await fs.promises.writeFile(
			protectionjsFile,
			`import FactoryMaker from '../../core/FactoryMaker.js';` + protectionjs.replace(/dashjs\./g, '')
		);
		const mssHandlerjsFile = path.join(dashjsDir, 'src', 'mss', 'MssHandler.js');
		const mssHandlerjs = await fs.promises.readFile(mssHandlerjsFile, 'utf8');
		await fs.promises.writeFile(
			mssHandlerjsFile,
			`import FactoryMaker from '../core/FactoryMaker.js';` + mssHandlerjs.replace(/dashjs\./g, '')
		);
		const cfgFile2 = path.join(dashjsDir, 'build', 'webpack', 'common', 'webpack.common.base.cjs');
		const cfg2 = await fs.promises.readFile(cfgFile2, 'utf8');
		await fs.promises.writeFile(cfgFile2, cfg2.replace(/const prodEntries = \{[^}]+}/, `const prodEntries = {'dash.mediaplayer': './index_mediaplayerOnly.js'}`));
		const cfgFile3 = path.join(dashjsDir, 'build', 'webpack', 'common', 'webpack.common.prod.cjs');
		const cfg3 = await fs.promises.readFile(cfgFile3, 'utf8');
		await fs.promises.writeFile(cfgFile3, cfg3.replace(/\s{2,}plugins/g, ''));
		const cfgFile4 = path.join(dashjsDir, 'package.json');
		const cfg4 = await fs.promises.readFile(cfgFile4, 'utf8');
		await fs.promises.writeFile(cfgFile4, cfg4.replace(/ && npm run test && npm run lint/, ''));

		console.log(`Building dash.js...`);
		child_process.execSync(`npm run build-modern`, { cwd: dashjsDir });
		const dashjs = (await fs.promises.readFile(path.join(dashjsDir, 'dist', 'modern', 'esm', 'dash.mediaplayer.min.js'), 'utf8')).replace(/^\/*[^\n]+\n|\.default;export{\S+? as default};\n.+?$/g, '').replace(/var \w+?=(?=\([^\)]+\)$)/, 'return'),
			mediaplayerPlugin = await fs.promises.readFile(path.join(__dirname, 'MediaplayerPlugin.js'), 'utf8'),
			mediaplayer = `
				'use strict';
				(()=>{
				const Hls = Error().stack.startsWith('@') ? null : ${hlsjs};
				const Dash = typeof ManagedMediaSource === 'function' || typeof MediaSource === 'function' ? (()=>{${dashjs}})() : null;
				${mediaplayerPlugin}
				})();
			`;
		await fs.promises.writeFile(path.join(__dirname, 'mediaplayer.js'), (await terser.minify(mediaplayer)).code);
		console.log('mediaplayer.js has been generated.\nYou may update your project with this command: `dart run mediaplayer:webinit`.');
	}
})();