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
		res = await fetch('https://github.com/video-dev/hls.js/releases/latest', {
			method: 'HEAD',
			redirect: 'manual'
		}),
		version = res.headers.get('location').match(/v\d+\.\d+\.\d+$/);
	res.arrayBuffer();
	if (!version) {
		console.error('Failed to get the latest version of hls.js');
	} else {
		const hlsjsDir = path.join(__dirname, 'hls.js');
		if (fs.existsSync(hlsjsDir)) {
			console.log(`Updateing hls.js...`);
			child_process.execSync(`git reset --hard`, { cwd: hlsjsDir });
			child_process.execSync(`git checkout master`, { cwd: hlsjsDir });
			child_process.execSync(`git pull`, { cwd: hlsjsDir });
		} else {
			console.log(`Cloning hls.js...`);
			child_process.execSync(`git clone https://github.com/video-dev/hls.js.git`);
		}
		console.log(`Initializing hls.js...`);
		child_process.execSync(`git checkout tags/${version[0]}`, { cwd: hlsjsDir });
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
		const hlsjs = await fs.promises.readFile(path.join(hlsjsDir, 'dist', 'hls.js'), 'utf8'),
			mediaplayerPlugin = await fs.promises.readFile(path.join(__dirname, 'MediaplayerPlugin.js'), 'utf8'),
			mediaplayer = `
				'use strict';
				(()=>{
				const Hls = Error().stack.startsWith('@') ? null : ${hlsjs.replace(/\(function \(global, factory\) \{.+?'use strict';/s, '')
					.replace(/}\)\);\s+}\)\(false\);\s+\/\/# sourceMappingURL=hls\.js\.map/, '})(false)')
					.replace(/var exports=\{};var module=\{exports:exports};function define\(f\)\{f\(\)};define\.amd=true;/, `'use strict';`)
					.replace(/var canCreateWorker =.+?if (canCreateWorker) {|if \(config.workerPath\) \{.+?} else \{/s, 'if (true) {')
				};
				${mediaplayerPlugin}
				})();
			`;
		await fs.promises.writeFile(path.join(__dirname, 'mediaplayer.js'), (await terser.minify(mediaplayer)).code);
		console.log('mediaplayer.js has been generated.\nYou may update your project with this command: `dart run mediaplayer:webinit`.');
	}
})();