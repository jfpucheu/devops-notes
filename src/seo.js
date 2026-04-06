// Inject SEO meta tags dynamically per page
(function () {
  const SITE_NAME = 'Devops-Notes — jfpucheu';
  const SITE_URL  = 'https://devops-notes.com/';

  // Title: use H1 content + site name
  const h1 = document.querySelector('h1');
  if (h1) {
    document.title = h1.textContent.trim() + ' | ' + SITE_NAME;
  }

  // Meta description: use first paragraph after H1
  let desc = '';
  if (h1) {
    let el = h1.nextElementSibling;
    while (el && !desc) {
      if (el.tagName === 'P') desc = el.textContent.trim().slice(0, 155);
      el = el.nextElementSibling;
    }
  }
  if (desc) {
    let meta = document.querySelector('meta[name="description"]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.name = 'description';
      document.head.appendChild(meta);
    }
    meta.content = desc;
  }

  // Canonical URL
  const path = window.location.pathname;
  let canonical = document.querySelector('link[rel="canonical"]');
  if (!canonical) {
    canonical = document.createElement('link');
    canonical.rel = 'canonical';
    document.head.appendChild(canonical);
  }
  canonical.href = SITE_URL + path.replace(/^\/devops-notes\//, '');

  // Open Graph tags
  const og = (prop, content) => {
    let el = document.querySelector(`meta[property="${prop}"]`);
    if (!el) {
      el = document.createElement('meta');
      el.setAttribute('property', prop);
      document.head.appendChild(el);
    }
    el.content = content;
  };
  og('og:type',        'article');
  og('og:site_name',   SITE_NAME);
  og('og:title',       document.title);
  og('og:description', desc);
  og('og:url',         canonical.href);
})();
