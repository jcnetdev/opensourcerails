if (typeof(Delicious)=='undefined') Delicious = {};
if (typeof(Delicious.BlogBadge)=='undefined') {

    if (!Object.prototype.hasOwnProperty) {
        Object.prototype.hasOwnProperty = function(p) {
            return (typeof this[p] != 'undefined') && 
                (this.constructor.prototype[p] !== this[p]);
        }
    }

    Delicious.BlogBadge = function() {
        return {

            DEBUG:           false,
            hostname:        Delicious.HOSTNAME || 'del.icio.us',
            json_hostname:   Delicious.JSON_HOSTNAME || Delicious.HOSTNAME || 'badges.del.icio.us',
            static_url_root: Delicious.STATIC_URL_ROOT || 'http://images.del.icio.us/static',
            default_class:   "delicious-blogbadge-tall",
            posts_count:     5,

            did_init:        false,
            badges:          {},

            log: function(msg) {
                if (this.DEBUG) if (window.console && console.log) 
                    console.log(msg);
            },

            init: function() {
                if (arguments.callee.done) return;
                arguments.callee.done = true;

                if (Delicious.BLOGBADGE_DEFAULT_CLASS) {
                    Delicious.BlogBadge.default_class = Delicious.BLOGBADGE_DEFAULT_CLASS;
                }

                this.badges = {};
                // HACK:  Packed version of md5.js is at the bottom of this file.
                // this.insertExtJSLibs();
                this.insertBadgeCSS();
                this.addLoadEvent(this.onload);
            },

            onload: function() {
                if (arguments.callee.done) return;
                arguments.callee.done = true;

                for (u in this.badges) {
                    if (!this.badges.hasOwnProperty(u)) continue;
                    var badge = this.badges[u];
                    if (!badge.hash)
                        badge.hash = hex_md5(u);
                }
                this.fetchBadgeJSON();
            },

            insertExtJSLibs: function() {
                this.forEach([ 
                    this.static_url_root+'/js/md5.js' 
                ], function(u) {
                    var scr = document.createElement("script");
                    scr.setAttribute("type", "text/javascript");
                    scr.setAttribute("src", u);
                    document.getElementsByTagName("head").item(0).appendChild(scr);
                });
            },

            insertBadgeCSS: function() {
                var bcss = document.getElementById('delicious-blogbadge-css');
                if (!bcss) {
                    bcss = this.el('link', {
                        'id':   'delicious-blogbadge-css',
                        'type': 'text/css',
                        'rel':  'stylesheet',
                        'href': this.static_url_root+'/css/blogbadge.css'
                    }, []);
                    document.getElementsByTagName('head')[0].appendChild(bcss);
                }
                bcss = null;
            },

            register: function(divid, url, title, opts) {
                var badge = { 
                    'divid': divid, 
                    'url': url, 
                    //'hash': hex_md5(url),
                    'title':title, 
                    'opts': opts||{} 
                };
                this.badges[url] = badge;
                this.replaceChildNodes(
                    document.getElementById(badge.divid), 
                    this.renderPostButton(badge)
                );
            },

            writeBadge: function(divid, url, title, opts, classname) {
                if (!classname) classname = this.default_class;
                document.writeln('<div class="'+classname+'" id="'+divid+'"></div>');
                this.register(divid, url, title, opts);
            },

            fetchBadgeJSON: function() {
                var json_url = "http://"+this.json_hostname +
                    "/feeds/json/url/blogbadge" +
                    "?callback=Delicious.BlogBadge.handleBadgeJSON" + 
                    "&noCacheIE="+(new Date()).getTime();

                var showposts = false;
                for (u in this.badges) {
                    if (!this.badges.hasOwnProperty(u)) continue;
                    var badge = this.badges[u];
                    json_url += "&hash="+encodeURIComponent(badge.hash);
                    if (!showposts && badge.opts.showposts) {
                        showposts = true;
                        json_url += "&showposts=yes&count="+this.posts_count;
                    }
                }

                // TODO: Make work in XHTML pages with namespaces.
                var scr = document.createElement("script");
                scr.setAttribute("type", "text/javascript");
                scr.setAttribute("src", json_url);
                scr.setAttribute("id", 'delicious-blogbadge-json');

                this.script_ele = scr;
                document.getElementsByTagName("head").item(0).appendChild(this.script_ele);
            },

            handleBadgeJSON: function(data) {

                for (var i=0,rec; rec=data[i]; i++) {
                    var badge = this.badges[rec.url];
                    if (badge && !badge.loaded) {
                        this.buildBadge(badge, rec); 
                        badge.loaded = true;
                    }
                }

                for (u in this.badges) {
                    if (!this.badges.hasOwnProperty(u)) continue;
                    var badge = this.badges[u];
                    if (badge.loaded) continue;
                    this.buildBadge(badge, {
                        url: u, total_posts: 0, top_tags: []
                    });
                }

                document.getElementsByTagName("head").item(0).removeChild(this.script_ele);
                this.script_ele = null;

            },

            buildBadge: function(badge, data) {
                badge.data = data;
                this.replaceChildNodes(
                    document.getElementById(badge.divid), 
                    this.renderBadge(badge)
                );
            },

            buildPostURL: function(badge) {
                return 'http://'+this.hostname+'/post'+
                    '?url='+encodeURIComponent(badge.url)+
                    '&title='+encodeURIComponent(badge.title || '')+
                    '&jump=no&partner=delbg';
            },

            renderPostButton: function(badge) {
                var el       = this.bind(this.el);
                var post_url = this.buildPostURL(badge);

                return [
                    el('a', {'class':'save-to-link', 'href':post_url, 'title':'bookmark '+badge.title+' on del.icio.us'}, [
                        el('span', {'class':'save-to-link-label'}, ['bookmark this on del.icio.us'])
                    ])
                ];
            },

            renderBadge: function(badge) {
                var el          = this.bind(this.el);
                var map         = this.bind(this.map);
                var data        = badge.data;
                var total_posts = data.total_posts || 0;

                var top_tags = []; 
                for (t in data.top_tags) {
                    if (!data.top_tags.hasOwnProperty(t)) continue;
                    top_tags.push(t);
                }
                top_tags.sort(function(a,b) {
                    return ( data.top_tags[b] - data.top_tags[a] );
                });

                var posts = [];
                if (badge.opts.showposts) {
                    for (var i=0, post; (i<this.posts_count) && (post=badge.data.posts[i]); i++) {
                        posts.push(post);
                    }
                }

                var post_bookmark_url = this.buildPostURL(badge);

                return [

                    this.renderPostButton(badge),

                    (total_posts > 0) ? 
                        el('a', {'class':'url-link', 'href':'http://'+this.hostname+'/url/'+data.hash}, [
                            el('span', {'class':'post-count-label-before'}, ['saved by ']),
                            el('span', {'class':'post-count'}, [ total_posts ]),
                            el('span', {'class':'post-count-label-after'}, 
                                (total_posts>1) ? [' other people'] : [' other person']
                            ),
                        ])
                        :
                        [
                            el('a', {'class':'empty-save-to-link', 'href':post_bookmark_url}, [
                                el('span', {'class':'empty-save-to-link-label'}, ['save this']),
                            ]),
                            el('span', {'class':'empty-message'}, [
                                'be the first to bookmark this page!'
                            ])
                        ],

                    (! (total_posts > 0 && top_tags.length > 0) ) ? '' :  [
                        el('div', {'class':'top-tags-container'}, [
                            el('span', {'class':'top-tags-title'}, ['tags: ']),
                            el('ul', {'class':'top-tags'},
                                map(function(t) {
                                    return [ el('li', {}, [
                                        el('a', {'href':'http://'+this.hostname+'/tag/'+t, 'title':t}, [t])
                                    ]), ' ' ];
                                }, top_tags)
                            )
                        ])
                    ],

                    (! (badge.opts.showposts && posts.length) ) ? '' : [ 

                        el('span', {'class':'latest-posts'}, [
                            el('span', {'class':'latest-posts-label'}, ['recent bookmarks: ']),

                            el('ul', {}, map( function(post) {

                                return el('li', {'class':'xfolkentry'}, [

                                    el('a', {'class':'taggedlink', 'href':post.u}, [post.n]),
                                    (!post.d) ? '' : el('blockquote', {'class':'description'}, [post.d]),
                                    el('div', {'class':'meta'}, [

                                        el('span', {'class':'meta-label-by'}, [' by ']),
                                        el('a', {'class':'author', 'href':'http://'+this.hostname+'/'+post.un}, [post.un]),
                                        (!post.t.length) ? '' : [
                                            el('span', {'class':'meta-label-to'}, [' to ']),
                                            el('ul', {'class':'tags'}, map(function(t) {
                                                return [ el('li', {'class':'tag'}, [
                                                    el('a', {'rel':'tag', 'href':'http://'+this.hostname+'/'+post.un+'/tag/'+t}, [t])
                                                ]), ' '];
                                            }, post.t))
                                        ],
                                        el('span', {'class':'meta-label-at'}, [' at ']),
                                        el('abbr', {'class':'created','title':post.dt+'Z'}, [post.dt+'Z']),

                                    ])
                                
                                ]);

                            }, posts))
                            
                        ]),
                    
                    ],

                    ' ',
                    el('br',{},[])
                ];

            },

            bind: function(func) {
                var obj = this;
                return function() { return func.apply(obj, arguments) };
            },

            forEach: function(list, fn) {
                fn = this.bind(fn);
                for (var i=0; i<list.length; i++) fn(list[i]);
            },

            filter: function(fn, list) {
                var rv = [];
                fn = this.bind(fn);
                for (var i=0; i<list.length; i++)
                    if (fn(list[i])) rv[rv.length] = list[i];
                return rv;
            },

            map: function(fn, list) {
                var rv = [];
                fn = this.bind(fn);
                for (var i=0; i<list.length; i++) rv[rv.length] = fn(list[i]);
                return rv;
            },

            addLoadEvent_classic: function(func) {
                var init = this.bind(func);

                // for anyone else not covered above.
                var oldonload = window.onload;
                if (typeof window.onload != 'function') {
                    window.onload = init;
                } else {
                    window.onload = function() {
                        if (oldonload) { oldonload(); }
                        init();
                    }
                }
            },

            // See: http://dean.edwards.name/weblog/2006/06/again/
            addLoadEvent: function(func) {
                var init = this.bind(func);

                // for Mozilla and Opera browsers
                if (document.addEventListener) {
                    document.addEventListener("DOMContentLoaded", init, false);
                }

                // for Internet Explorer (using conditional comments)
                /*@cc_on @*/
                /*@if (@_win32)
                document.write("<script id=__ie_onload defer src=javascript:void(0)><\/script>");
                var script = document.getElementById("__ie_onload");
                script.onreadystatechange = function() {
                    if (this.readyState == "complete") {
                        init(); // call the onload handler
                    }
                };
                /*@end @*/
                 
                // for WebKit browsers
                if (/WebKit/i.test(navigator.userAgent)) { // sniff
                    var _timer = setInterval(function() {
                        if (/loaded|complete/.test(document.readyState)) {
                            clearInterval(_timer);
                            init(); // call the onload handler
                        }
                    }, 10);
                }

                // for anyone else not covered above.
                var oldonload = window.onload;
                if (typeof window.onload != 'function') {
                    window.onload = init;
                } else {
                    window.onload = function() {
                        if (oldonload) { oldonload(); }
                        init();
                    }
                }
            },

            replaceChildNodes: function(parent, nodes) {
                while (parent.firstChild) 
                    parent.removeChild(parent.firstChild);
                return this.appendChildNodes(parent, nodes);
            },

            appendChildNodes: function(parent, nodes) {
                if (!nodes || !nodes.length) return;
                for (var i=0; i<nodes.length; i++) {
                    var node = nodes[i];
                    if (!node) continue;
                    if (node.nodeType) 
                        parent.appendChild(node);
                    else if ( (typeof(node) == 'object') && node.length)
                        this.appendChildNodes(parent, node);
                    else
                        parent.appendChild(document.createTextNode(''+node));
                }
            },

            el: function(name, attrs, nodes) {
                var elem = document.createElement(name);
                if (attrs) for (k in attrs) {
                    if (!attrs.hasOwnProperty(k)) continue;
                    var v = attrs[k];

                    if (k.substring(0, 2) == "on") {
                        if (typeof(v) == "string") {
                            v = new Function(v);
                        }
                        elem[k] = v;
                    } else {
                        elem.setAttribute(k, v);
                    }

                    switch(k) {
                        // MSIE seems to want this.
                        case 'class': elem.className = v; break;
                    }
                }
                if (nodes) this.appendChildNodes(elem, nodes);
                return elem;
            },

            EOF:null
        };
    }();
}

// HACK: Packed version of http://pajhome.org.uk/crypt/md6/md5.js
eval(function(p,a,c,k,e,d){e=function(c){return(c<a?'':e(parseInt(c/a)))+((c=c%a)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--){d[e(c)]=k[c]||e(c)}k=[function(e){return d[e]}];e=function(){return'\\w+'};c=1};while(c--){if(k[c]){p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c])}}return p}('e 1i=0;e 1g="";e p=8;f 1f(s){g K(A(D(s),s.o*p))}f 1w(s){g S(A(D(s),s.o*p))}f 1N(s){g L(A(D(s),s.o*p))}f 2b(w,v){g K(I(w,v))}f 2a(w,v){g S(I(w,v))}f 2c(w,v){g L(I(w,v))}f 2i(){g 1f("1R")=="1O"}f A(x,G){x[G>>5]|=1U<<((G)%E);x[(((G+1V)>>>9)<<4)+14]=G;e a=24;e b=-1Y;e c=-1X;e d=2h;z(e i=0;i<x.o;i+=16){e Y=a;e W=b;e X=c;e 1b=d;a=l(a,b,c,d,x[i+0],7,-2d);d=l(d,a,b,c,x[i+1],12,-28);c=l(c,d,a,b,x[i+2],17,29);b=l(b,c,d,a,x[i+3],22,-1T);a=l(a,b,c,d,x[i+4],7,-1Z);d=l(d,a,b,c,x[i+5],12,2j);c=l(c,d,a,b,x[i+6],17,-1P);b=l(b,c,d,a,x[i+7],22,-1Q);a=l(a,b,c,d,x[i+8],7,1S);d=l(d,a,b,c,x[i+9],12,-25);c=l(c,d,a,b,x[i+10],17,-26);b=l(b,c,d,a,x[i+11],22,-2f);a=l(a,b,c,d,x[i+12],7,2e);d=l(d,a,b,c,x[i+13],12,-2g);c=l(c,d,a,b,x[i+14],17,-27);b=l(b,c,d,a,x[i+15],22,1M);a=h(a,b,c,d,x[i+1],5,-1t);d=h(d,a,b,c,x[i+6],9,-1s);c=h(c,d,a,b,x[i+11],14,1u);b=h(b,c,d,a,x[i+0],20,-1v);a=h(a,b,c,d,x[i+5],5,-1r);d=h(d,a,b,c,x[i+10],9,1q);c=h(c,d,a,b,x[i+15],14,-1l);b=h(b,c,d,a,x[i+4],20,-1k);a=h(a,b,c,d,x[i+9],5,1m);d=h(d,a,b,c,x[i+14],9,-1n);c=h(c,d,a,b,x[i+3],14,-1p);b=h(b,c,d,a,x[i+8],20,1o);a=h(a,b,c,d,x[i+13],5,-1x);d=h(d,a,b,c,x[i+2],9,-1y);c=h(c,d,a,b,x[i+7],14,1I);b=h(b,c,d,a,x[i+12],20,-1H);a=k(a,b,c,d,x[i+5],4,-1J);d=k(d,a,b,c,x[i+8],11,-1K);c=k(c,d,a,b,x[i+11],16,1L);b=k(b,c,d,a,x[i+14],23,-1G);a=k(a,b,c,d,x[i+1],4,-1F);d=k(d,a,b,c,x[i+4],11,1A);c=k(c,d,a,b,x[i+7],16,-1z);b=k(b,c,d,a,x[i+10],23,-1B);a=k(a,b,c,d,x[i+13],4,1C);d=k(d,a,b,c,x[i+0],11,-1E);c=k(c,d,a,b,x[i+3],16,-1D);b=k(b,c,d,a,x[i+6],23,1W);a=k(a,b,c,d,x[i+9],4,-2z);d=k(d,a,b,c,x[i+12],11,-2F);c=k(c,d,a,b,x[i+15],16,2G);b=k(b,c,d,a,x[i+2],23,-2D);a=m(a,b,c,d,x[i+0],6,-2B);d=m(d,a,b,c,x[i+7],10,2I);c=m(c,d,a,b,x[i+14],15,-2O);b=m(b,c,d,a,x[i+5],21,-2M);a=m(a,b,c,d,x[i+12],6,2J);d=m(d,a,b,c,x[i+3],10,-2H);c=m(c,d,a,b,x[i+10],15,-2A);b=m(b,c,d,a,x[i+1],21,-2p);a=m(a,b,c,d,x[i+8],6,2q);d=m(d,a,b,c,x[i+15],10,-2o);c=m(c,d,a,b,x[i+6],15,-2n);b=m(b,c,d,a,x[i+13],21,2m);a=m(a,b,c,d,x[i+4],6,-2r);d=m(d,a,b,c,x[i+11],10,-2k);c=m(c,d,a,b,x[i+2],15,2y);b=m(b,c,d,a,x[i+9],21,-2t);a=u(a,Y);b=u(b,W);c=u(c,X);d=u(d,1b)}g H(a,b,c,d)}f F(q,a,b,x,s,t){g u(Z(u(u(a,q),u(x,t)),s),b)}f l(a,b,c,d,x,s,t){g F((b&c)|((~b)&d),a,b,x,s,t)}f h(a,b,c,d,x,s,t){g F((b&d)|(c&(~d)),a,b,x,s,t)}f k(a,b,c,d,x,s,t){g F(b^c^d,a,b,x,s,t)}f m(a,b,c,d,x,s,t){g F(c^(b|(~d)),a,b,x,s,t)}f I(w,v){e C=D(w);1d(C.o>16)C=A(C,w.o*p);e P=H(16),V=H(16);z(e i=0;i<16;i++){P[i]=C[i]^2L;V[i]=C[i]^2N}e 1c=A(P.18(D(v)),19+v.o*p);g A(V.18(1c),19+2C)}f u(x,y){e O=(x&N)+(y&N);e 1a=(x>>16)+(y>>16)+(O>>16);g(1a<<16)|(O&N)}f Z(T,M){g(T<<M)|(T>>>(E-M))}f D(n){e B=H();e J=(1<<p)-1;z(e i=0;i<n.o*p;i+=p)B[i>>5]|=(n.2l(i/p)&J)<<(i%E);g B}f L(B){e n="";e J=(1<<p)-1;z(e i=0;i<B.o*E;i+=p)n+=2s.2x((B[i>>5]>>>(i%E))&J);g n}f K(r){e U=1i?"2w":"2v";e n="";z(e i=0;i<r.o*4;i++){n+=U.R((r[i>>2]>>((i%4)*8+4))&1e)+U.R((r[i>>2]>>((i%4)*8))&1e)}g n}f S(r){e 1h="2u+/";e n="";z(e i=0;i<r.o*4;i+=3){e 1j=(((r[i>>2]>>8*(i%4))&Q)<<16)|(((r[i+1>>2]>>8*((i+1)%4))&Q)<<8)|((r[i+2>>2]>>8*((i+2)%4))&Q);z(e j=0;j<4;j++){1d(i*8+j*6>r.o*E)n+=1g;2K n+=1h.R((1j>>6*(3-j))&2E)}}g n}',62,175,'||||||||||||||var|function|return|md5_gg|||md5_hh|md5_ff|md5_ii|str|length|chrsz||binarray|||safe_add|data|key|||for|core_md5|bin|bkey|str2binl|32|md5_cmn|len|Array|core_hmac_md5|mask|binl2hex|binl2str|cnt|0xFFFF|lsw|ipad|0xFF|charAt|binl2b64|num|hex_tab|opad|oldb|oldc|olda|bit_rol|||||||||concat|512|msw|oldd|hash|if|0xF|hex_md5|b64pad|tab|hexcase|triplet|405537848|660478335|568446438|1019803690|1163531501|187363961|38016083|701558691|1069501632|165796510|643717713|373897302|b64_md5|1444681467|51403784|155497632|1272893353|1094730640|681279174|722521979|358537222|1530992060|35309556|1926607734|1735328473|378558|2022574463|1839030562|1236535329|str_md5|900150983cd24fb0d6963f7d28e17f72|1473231341|45705983|abc|1770035416|1044525330|0x80|64|76029189|1732584194|271733879|176418897|||||1732584193|1958414417|42063|1502002290|389564586|606105819|b64_hmac_md5|hex_hmac_md5|str_hmac_md5|680876936|1804603682|1990404162|40341101|271733878|md5_vm_test|1200080426|1120210379|charCodeAt|1309151649|1560198380|30611744|2054922799|1873313359|145523070|String|343485551|ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789|0123456789abcdef|0123456789ABCDEF|fromCharCode|718787259|640364487|1051523|198630844|128|995338651|0x3F|421815835|530742520|1894986606|1126891415|1700485571|else|0x36363636|57434055|0x5C5C5C5C|1416354905'.split('|'),0,{}))

Delicious.BlogBadge.init();
if (!Delicious.BLOGBADGE_MANUAL_MODE) {
    Delicious.BlogBadge.writeBadge("delicious-blogbadge-"+Math.random(), "http://www.opensourcerails.com", document.title, {});
    Delicious.BlogBadge.onload();
}
