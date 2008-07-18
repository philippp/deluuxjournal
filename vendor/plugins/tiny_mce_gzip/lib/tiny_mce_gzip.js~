var tinyMCE_GZ = {
	settings : {
		plugins : 'style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras',
		themes : 'simple,advanced',
		languages : 'en',
		page_name : 'tiny_mce_gzip',
		check : true
	},

	init : function(s) {
		var n, d = document, nl, i, b = '', sr, db;

		this.isIE = (navigator.appName == "Microsoft Internet Explorer");
		this.isOpera = navigator.userAgent.indexOf('Opera') != -1;

		for (n in s)
			this.settings[n] = s[n];

		for (i=0, nl = d.getElementsByTagName('base'); i<nl.length; i++) {
			if (nl[i].href)
				b = nl[i].href;
		}

		for (i=0, nl = d.getElementsByTagName('script'); i<nl.length; i++) {
			if (nl[i].src && nl[i].src.indexOf('tiny_mce_gzip') != -1) {
				sr = nl[i].src;
				sr = sr.substring(0, sr.lastIndexOf('/'));

				if (b != '' && b.indexOf('://') == -1)
					b += sr;
				else
					b = sr;
			}
		}

		db = document.location.href;

		if (db.indexOf('?') != -1)
			db = db.substring(0, db.indexOf('?'));

		db = db.substring(0, db.lastIndexOf('/'));

		if (b.indexOf('://') == -1 && b.charAt(0) != '/')
			b = db + "/" + b;

		this.baseURL = b + '/';
		this.load(this.settings.page_name);
	},

	load : function(v) {
		var s = this.settings, h, d = document;

		v += '_js.js?plugins=' + escape(s.plugins);
		v += '&themes=' + escape(s.themes);
		v += '&languages=' + escape(s.languages);
		v += '&diskcache=' + (s.disk_cache ? 'true' : 'false');

		this.loadFile(this.baseURL + v);

		if (s.check) {
			if (this.isIE && !this.isOpera)
				d.write('<script type="text/javascript" src="' + tinyMCE_GZ.baseURL + s.page_name + '_check.js?"></script>');
			else
				d.write("<script type=\"text/javascript\">tinyMCE_GZ.check();</script>");
		}
	},

	loadFile : function(u) {
		document.write('<script type="text/javascript" src="' + u + '"></script>');
	},

	start : function() {
		var s = this.settings, p = TinyMCE_Engine.prototype;

		p.__loadScript = p.loadScript;
		p.__importThemeLanguagePack = p.importThemeLanguagePack;
		p.__importPluginLanguagePack = p.importPluginLanguagePack;
		p.__loadNextScript = p.loadNextScript;
		p.loadScript = p.importThemeLanguagePack = p.importPluginLanguagePack = p.loadNextScript = function() {};
		tinyMCE.baseURL = this.baseURL.substring(0, this.baseURL.length - 1);
		tinyMCE.settings = {};
		tinyMCE.srcMode = '';
	},

	end : function() {
		var s = this.settings, l = tinyMCE.loadedFiles, la, i, p = TinyMCE_Engine.prototype;

		this.addFiles(s.plugins, 'plugins', 'editor_plugin.js');
		this.addFiles(s.themes, 'themes', 'editor_template.js');

		la = s.languages.replace(/\s+/, '').split(',')
		for (i=0; i<la.length; i++)
			l[l.length] = this.baseURL + 'langs/' + la[i] + '.js';

		p.loadScript = p.__loadScript;
		p.importThemeLanguagePack = p.__importThemeLanguagePack;
		p.importPluginLanguagePack = p.__importPluginLanguagePack;
		p.loadNextScript = p.__loadNextScript;
	},

	check : function() {
		if (typeof(tinyMCE) == 'undefined')
			this.loadFile(this.baseURL + 'tiny_mce.js');
	},

	addFiles : function(f, c, e) {
		var i, a, s = this.settings, l = tinyMCE.loadedFiles, la, x;

		a = f.replace(/\s+/, '').split(',');
		for (i=0; i<a.length; i++) {
			if (a[i]) {
				l[l.length] = this.baseURL + c + '/' +  a[i] + '/' + e;

				la = s.languages.replace(/\s+/, '').split(',')
				for (x=0; x<la.length; x++)
					l[l.length] = this.baseURL + c + '/' +  a[i] + '/langs/' + la[x] + '.js';
			}
		}
	}
};
