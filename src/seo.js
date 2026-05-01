(function () {
  const SITE_NAME  = 'Devops-Notes';
  const SITE_URL   = 'https://devops-notes.com';
  const AUTHOR     = 'Jean-François Pucheu';
  const AUTHOR_URL = 'https://github.com/jfpucheu';

  // ── Helpers ───────────────────────────────────────────────────────────────
  function setMeta(name, content, attr) {
    if (!content) return;
    attr = attr || 'name';
    var el = document.querySelector('meta[' + attr + '="' + name + '"]');
    if (!el) { el = document.createElement('meta'); el.setAttribute(attr, name); document.head.appendChild(el); }
    el.content = content;
  }
  function setOg(prop, content) { setMeta(prop, content, 'property'); }
  function setLink(rel, href) {
    var el = document.querySelector('link[rel="' + rel + '"]');
    if (!el) { el = document.createElement('link'); el.rel = rel; document.head.appendChild(el); }
    el.href = href;
  }
  function addJsonLd(data) {
    var el = document.createElement('script');
    el.type = 'application/ld+json';
    el.textContent = JSON.stringify(data);
    document.head.appendChild(el);
  }

  // ── Content extraction ────────────────────────────────────────────────────
  var h1       = document.querySelector('h1');
  var pageTitle = h1 ? h1.textContent.trim() : document.title.split(' - ')[0];
  var path     = window.location.pathname.replace(/\/index\.html$/, '/');
  var isHome   = path === '/' || path === '';
  var canonicalUrl = SITE_URL + (path || '/');

  // First substantial paragraph after H1
  var desc = '';
  if (h1) {
    var el = h1.nextElementSibling;
    while (el && !desc) {
      if (el.tagName === 'P') {
        var text = el.textContent.trim();
        if (text.length > 40) desc = text.slice(0, 155);
      }
      el = el.nextElementSibling;
    }
  }
  if (!desc) {
    var p = document.querySelector('.content p');
    if (p) desc = p.textContent.trim().slice(0, 155);
  }

  // ── Title ─────────────────────────────────────────────────────────────────
  document.title = isHome
    ? SITE_NAME + ' — DevOps & Kubernetes Field Notes'
    : pageTitle + ' | ' + SITE_NAME;

  // ── Core meta ─────────────────────────────────────────────────────────────
  setLink('canonical', canonicalUrl);
  setMeta('description', desc);

  // ── Open Graph ────────────────────────────────────────────────────────────
  setOg('og:type',        isHome ? 'website' : 'article');
  setOg('og:site_name',   SITE_NAME);
  setOg('og:title',       document.title);
  setOg('og:description', desc);
  setOg('og:url',         canonicalUrl);
  setOg('og:locale',      'en_US');

  // ── Twitter Cards ─────────────────────────────────────────────────────────
  setMeta('twitter:title',       document.title);
  setMeta('twitter:description', desc);

  // ── JSON-LD ───────────────────────────────────────────────────────────────
  var authorObj = { '@type': 'Person', name: AUTHOR, url: AUTHOR_URL,
    sameAs: ['https://github.com/jfpucheu', 'https://www.linkedin.com/in/jfpucheu/', 'https://medium.com/@jfpucheu'] };

  if (isHome) {
    addJsonLd({
      '@context': 'https://schema.org',
      '@type': 'WebSite',
      name: SITE_NAME,
      url: SITE_URL + '/',
      description: 'Personal DevOps and Kubernetes field notes — Kubernetes, etcd, Cluster API, Kind, and more.',
      inLanguage: 'en',
      author: authorObj
    });
  } else {
    // TechArticle
    addJsonLd({
      '@context': 'https://schema.org',
      '@type': 'TechArticle',
      headline: pageTitle,
      description: desc,
      url: canonicalUrl,
      inLanguage: 'en',
      author: authorObj,
      publisher: authorObj,
      isPartOf: { '@type': 'WebSite', name: SITE_NAME, url: SITE_URL + '/' }
    });

    // BreadcrumbList
    var segments = path.replace(/\/$/, '').split('/').filter(Boolean);
    var items = [{ '@type': 'ListItem', position: 1, name: 'Home', item: SITE_URL + '/' }];
    var cumUrl = SITE_URL;
    segments.forEach(function (seg, i) {
      cumUrl += '/' + seg;
      var name = seg.replace(/\.html$/, '').replace(/[-_]/g, ' ')
        .replace(/\b\w/g, function (c) { return c.toUpperCase(); });
      items.push({ '@type': 'ListItem', position: i + 2, name: name, item: cumUrl });
    });
    addJsonLd({ '@context': 'https://schema.org', '@type': 'BreadcrumbList', itemListElement: items });
  }
})();
