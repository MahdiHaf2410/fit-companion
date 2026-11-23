// Fit Companion site
// 1) Scroll tour: the chapter in the middle of the screen picks the phone screen and the page colour,
//    and restarts that screen's animation.  2) Count-up numbers.  3) Arabic / English with RTL.
// 4) Latest release from GitHub (download links, version, size, change list follow every release).
(() => {
  const REPO = 'MahdiHaf2410/fit-companion';
  const root = document.documentElement;
  root.classList.add('js');

  // ---------------- translations ----------------
  const AR = {
    skip: 'انتقل إلى المحتوى', navTour: 'جولة في التطبيق', navChanges: 'آخر تحديث', navInstall: 'التثبيت', downloadShort: 'تحميل',
    h1a: 'سجّل التمرين.', h1b: 'غذِّ عضلاتك.', h1c: 'وشوف الأرقام تطلع.',
    lead: 'Fit Companion هو سجل تمارين، ومفكرة أكل، ومدرب، في تطبيق أندرويد واحد. يخدم بلا إنترنت، يهدر بالعربية والإنجليزية، ويعرف واش هي الكسرة والشوربة.',
    download: 'حمّل للأندرويد', tourCta: 'انزل لتحت وشوف كيفاش يخدم', version: 'الإصدار', free: 'مجاني وبلا إشهار.',
    pGood: 'مساء الخير', pPush: 'يوم الدفع', pWater: 'الماء', st1: 'رقم قياسي جديد 💪', st2: '+250 XP',
    tourTitle: 'انزل لتحت. التلفون يوريلك التطبيق.',
    pRest: 'راحة', pPr: 'رقم قياسي جديد: 100 كغ', pSearch: 'تفتيح بالدمبل',
    pChest: 'صدر', pBack: 'ظهر', pLegs: 'أرجل', pArms: 'ذراعين',
    pChestDb: 'صدر · دمبل', pChestBb: 'صدر · بار', pChestMa: 'صدر · آلة', pChestCa: 'صدر · كابل',
    pFound: 'لقينا 3 عناصر', pEggs: 'زوج بيضات', pKesra: 'كسرة، 80 غ', pCoffee: 'قهوة بالحليب',
    pWeek: '−0.4 كغ في الأسبوع، راك في الطريق', pBefore: 'جانفي', pAfter: 'درك',
    pCoach: 'المدرب الذكي', c1: 'كيفاش كان أسبوعي؟', c2a: '8.5 من 10.', c2b: 'أربع حصص، رقمين قياسيين، والبروتين كافي في خمس أيام.',
    c3: '🎤 زوج بيضات وطرف كسرة', c4: 'تزادو للفطور: 402 سعرة، 21 غ بروتين.',
    pLevel: 'المستوى', pWarrior: 'محارب', pLvlUp: 'طلعت للمستوى 12!', pLeader: 'الأصدقاء هاذ الأسبوع', pYou: 'أنت',
    k1: 'التمارين', h31: 'كل مجموعة تتسجّل بضغطة.', p31: 'علّم المجموعة ومؤقت الراحة يبدا في الإشعارات. ترفع أكثر من أي مرة قبل؟ التطبيق يقولك ديريكت.',
    l11: 'برامجك أنت، ولا ابدا من برنامج جاهز', l12: 'سوبرسيت، دروب سيت، إحماء ومستوى المجهود (RPE)', l13: 'يقولك وقتاش تزيد الوزن ووقتاش ترتاح',
    k2: 'التمارين بالفيديو', h32: '420 تمرين، كل واحد بفيديو.', p32: 'قلّب بالعربية ولا بالإنجليزية، فلتر حسب العضلة ولا حسب واش كاين في الجيم تاعك، وشوف كيفاش يتدار قبل أول تكرار.',
    l21: 'من الصدر حتى الرقبة، والكارديو', l22: 'بار، دمبل، آلة، كابل، كيتلبل، مطاط', l23: 'وتقدر تزيد تمارينك أنت',
    k3: 'التغذية', h33: 'صوّر صحنك. يحسبلك السعرات.', p33: 'صوّر صحنك، امسح الباركود، ولا غير قول واش كليت بالدارجة. الأكل الجزائري راهو في القائمة.',
    l31: 'البروتين والنشويات والدهون مقارنة بهدفك', l32: 'سعراتك الحقيقية للثبات، من تطوّر وزنك', l33: 'تتبّع الماء وتذكير بالوجبات',
    k4: 'التقدّم', h34: 'شوف التغيير، أسبوع بأسبوع.', p34: 'الوزن ونسبة الدهون والقياسات في منحنيات واضحة، وصور قبل وبعد جنب بعض. اربط Health Connect وشوف كيفاش النوم يحرّك أرقامك.',
    l41: 'صور التقدّم بالتاريخ', l42: 'قياسات الجسم ونسبة الدهون', l43: 'النوم مقارنة بتمرينك',
    k5: 'المدرب الذكي', h35: 'مدرب قرا سجلك.', p35: 'يجاوبك من أسبوعك أنت: واش رفعت، واش كليت وكيفاش رقدت. عمرو ما يشوف اسمك ولا إيميلك.',
    l51: 'تقرير أسبوعي بنقطة وثلاث أهداف', l52: 'برنامج مبني من تمارين التطبيق', l53: 'نهار كامل من الوجبات مع قائمة المشتريات',
    k6: 'التحديات', h36: 'اطلع في المستوى مع صحابك.', p36: 'التحديات الأسبوعية والشهرية تعطيك XP. زيد صحابك برمز وشوف شكون رفع أكثر هاذ الأسبوع.',
    l61: 'مستويات من مبتدئ حتى أسطورة', l62: 'ترتيب ما يشوفوه غير صحابك', l63: 'شارك تمرين ولا مستوى كصورة',
    n1: 'تمرين بأسماء عربية', n2: 'ثيم، فاتح وداكن', n3: 'لغات، من اليمين لليسار تاني', n4: 'إشهار، وبلا اشتراك',
    changesTitle: 'آخر تحديث', released: 'صدر في', allVersions: 'شوف كل الإصدارات', loading: 'جاري تحميل قائمة التغييرات.',
    installTitle: 'ثبّتو في دقيقة',
    s1: 'حمّل التطبيق', s1p: 'استعمل الزر اللي تحت. هو الملف المناسب لأغلب التلفونات اللي خرجو في آخر خمس سنين.',
    s2: 'اسمح بالتثبيت', s2p: 'أندرويد يسقسيك مرة وحدة إذا المتصفح يقدر يثبّت تطبيقات. قول إيه، ومن بعد افتح الملف.',
    s3: 'حدّث بنفس الطريقة', s3p: 'كي يخرج إصدار جديد، حمّلو من هاذ الصفحة وثبّتو فوق القديم. بياناتك تبقى.',
    older: 'تلفونك قبل 2018؟', armv7: 'حمّل نسخة 32-بت', unsure: 'ما راكش متأكد؟', universal: 'هاذي تخدم على كل التلفونات', bigger: 'بصح حجمها أكبر.',
    faqTitle: 'أسئلة يسقسيوها الناس',
    q1: 'هل هو مجاني بصح؟', a1: 'إيه. ما كاينش إشهار ولا اشتراك. أدوات الذكاء الاصطناعي عندها حد يومي باه تبقى مجانية للكل.',
    q2: 'وين تتحفظ بياناتي؟', a2: 'في تلفونك. إذا درت حساب، نسخة احتياطية تتحفظ أونلاين وحتى واحد ما يقراها غيرك. الأصدقاء يشوفو مستواك ومجموع أسبوعك برك.',
    q3: 'يحتاج الإنترنت؟', a3: 'لا، باه تسجّل التمارين والأكل والوزن. المدرب، فيديوهات الشرح، البحث بالباركود والنسخ الاحتياطي يحتاجو اتصال.',
    q4: 'كاين نسخة آيفون؟', a4: 'مازال. التطبيق يحتاج أندرويد 8.0 ولا أحدث.',
    q5: 'أندرويد يقولي تطبيق غير معروف. علاش؟', a5: 'التطبيق يتثبت من هاذ الموقع ماشي من Play Store، لهذا أندرويد يبيّن تحذير. الكود المصدري كامل متاح على GitHub إذا حبيت تتأكد.',
    madeBy: 'صمّمه وطوّره', devName: 'حفيان المهدي', source: 'الكود المصدري على GitHub',
  };
  const EN = {};
  document.querySelectorAll('[data-i18n]').forEach((el) => (EN[el.dataset.i18n] = el.textContent));
  const btn = document.getElementById('langBtn');
  let lang = 'en';
  try { lang = localStorage.getItem('fc_lang') || ((navigator.language || '').toLowerCase().startsWith('ar') ? 'ar' : 'en'); } catch (_) {}

  function applyLang(l) {
    lang = l;
    const dict = l === 'ar' ? AR : EN;
    root.lang = l;
    root.dir = l === 'ar' ? 'rtl' : 'ltr';
    document.querySelectorAll('[data-i18n]').forEach((el) => { const v = dict[el.dataset.i18n]; if (v) el.textContent = v; });
    btn.textContent = l === 'ar' ? 'English' : 'العربية';
    btn.lang = l === 'ar' ? 'en' : 'ar';
    try { localStorage.setItem('fc_lang', l); } catch (_) {}
    if (typeof setMode === 'function') setMode(root.dataset.mode === 'dark');
    renderRelease();
  }
  btn.addEventListener('click', () => applyLang(lang === 'ar' ? 'en' : 'ar'));

  // ---------------- light / dark ----------------
  const themeBtn = document.getElementById('themeBtn');
  const system = window.matchMedia('(prefers-color-scheme: dark)');
  function setMode(dark) {
    root.dataset.mode = dark ? 'dark' : 'light';
    themeBtn.setAttribute('aria-label', dark ? (lang === 'ar' ? 'الوضع الفاتح' : 'Switch to light mode') : (lang === 'ar' ? 'الوضع الداكن' : 'Switch to dark mode'));
    themeBtn.setAttribute('aria-pressed', String(dark));
    const ch = current; current = undefined; if (ch !== undefined) activate(ch); // repaint the chapter colour
  }
  themeBtn.addEventListener('click', () => {
    const dark = root.dataset.mode !== 'dark';
    root.dataset.theme = dark ? 'dark' : 'light';
    try { localStorage.setItem('fc_theme', root.dataset.theme); } catch (_) {}
    setMode(dark);
  });
  system.addEventListener('change', (e) => { if (!root.dataset.theme) setMode(e.matches); });

  // ---------------- count-up numbers ----------------
  const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const timers = new WeakMap();
  function countUp(el) {
    clearTimeout(timers.get(el));
    const to = parseFloat(el.dataset.to);
    const from = parseFloat(el.dataset.from || '0');
    const dec = parseInt(el.dataset.dec || '0', 10);
    const fmt = (v) => v.toFixed(dec);
    if (reduce) { el.textContent = fmt(to); return; }
    el.textContent = fmt(from);
    timers.set(el, setTimeout(() => {
      const start = performance.now();
      const dur = 1300;
      const step = (t) => {
        const k = Math.min(1, (t - start) / dur);
        const e = 1 - Math.pow(1 - k, 3);
        el.textContent = fmt(from + (to - from) * e);
        if (k < 1) requestAnimationFrame(step);
      };
      requestAnimationFrame(step);
    }, parseInt(el.dataset.delay || '0', 10)));
  }
  document.querySelectorAll('.hero .count').forEach(countUp);
  const numbers = document.querySelector('.numbers');
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver((entries) => entries.forEach((e) => {
      if (e.isIntersecting) { e.target.querySelectorAll('.count').forEach(countUp); io.unobserve(e.target); }
    }), { threshold: 0.4 });
    io.observe(numbers);
  } else numbers.querySelectorAll('.count').forEach(countUp);

  // ---------------- scroll tour ----------------
  const TINT = {
    light: {
      red: ['#ffe9ec', '#ff3b4f'], orange: ['#fff0e1', '#ff8a1f'], green: ['#e2f7ec', '#12b06a'],
      blue: ['#e6eeff', '#2f6bff'], violet: ['#efeaff', '#7b5cff'], yellow: ['#fff6d4', '#f5b800'],
    },
    dark: {
      red: ['#2a0f16', '#ff3b4f'], orange: ['#2a180a', '#ff8a1f'], green: ['#0a2418', '#12b06a'],
      blue: ['#0c1733', '#2f6bff'], violet: ['#1a1236', '#7b5cff'], yellow: ['#2a2208', '#f5b800'],
    },
  };
  const chapters = [...document.querySelectorAll('.chapter')];
  const screens = Object.fromEntries([...document.querySelectorAll('.scr')].map((s) => [s.dataset.scr, s]));
  let current = null;

  function activate(ch) {
    if (ch === current) return;
    current = ch;
    chapters.forEach((c) => c.classList.toggle('on', c === ch));
    if (!ch) {
      root.style.removeProperty('--tint');
      root.style.removeProperty('--accent');
      return;
    }
    const [tint, accent] = TINT[root.dataset.mode === 'dark' ? 'dark' : 'light'][ch.dataset.c];
    root.style.setProperty('--tint', tint);
    root.style.setProperty('--accent', accent);
    const target = screens[ch.dataset.show];
    Object.values(screens).forEach((s) => s.classList.remove('on'));
    void target.offsetWidth; // restart the screen's animations every time it comes back
    target.classList.add('on');
    target.querySelectorAll('.count').forEach(countUp);
  }

  let ticking = false;
  function onScroll() {
    ticking = false;
    // on phones the text card switches the screen as soon as it enters, so the animation plays above it
    const line = window.innerHeight * (window.innerWidth <= 960 ? 0.92 : 0.5);
    let hit = null;
    for (const c of chapters) {
      const r = c.getBoundingClientRect();
      if (r.top <= line && r.bottom >= line) { hit = c; break; }
    }
    // keep the last screen while between chapters inside the tour; reset colour outside it
    const tour = document.getElementById('tour').getBoundingClientRect();
    if (!hit && tour.top < line && tour.bottom > line) return;
    activate(hit);
  }
  window.addEventListener('scroll', () => { if (!ticking) { ticking = true; requestAnimationFrame(onScroll); } }, { passive: true });
  window.addEventListener('resize', onScroll);
  // the phone already shows the first screen before the first chapter is reached
  screens.workout.classList.add('on');

  // ---------------- latest release ----------------
  let release = null;
  const esc = (s) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const inline = (s) => esc(s).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
  function renderRelease() {
    if (!release) return;
    const parts = (release.body || '').split('<!-- ar -->');
    const text = (lang === 'ar' && parts[1] ? parts[1] : parts[0]).trim();
    const items = text.split('\n').map((l) => l.trim()).filter((l) => l.startsWith('- ')).map((l) => `<li>${inline(l.slice(2))}</li>`);
    document.getElementById('notes').innerHTML = items.length ? `<ul>${items.join('')}</ul>` : `<p>${inline(text)}</p>`;
    const t = document.getElementById('relDate');
    t.dateTime = release.published_at;
    t.textContent = new Date(release.published_at).toLocaleDateString(lang === 'ar' ? 'ar-DZ' : 'en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  }
  async function loadRelease() {
    try {
      const res = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, { headers: { Accept: 'application/vnd.github+json' } });
      if (!res.ok) throw new Error(String(res.status));
      release = await res.json();
      document.querySelectorAll('.ver').forEach((el) => (el.textContent = release.tag_name.replace(/^v/, '')));
      const find = (n) => (release.assets || []).find((a) => a.name === n);
      const point = (sel, n) => { const a = find(n); if (a) document.querySelectorAll(sel).forEach((el) => (el.href = a.browser_download_url)); return a; };
      const main = point('.dl-main', 'fit-companion-arm64.apk');
      point('.dl-armv7', 'fit-companion-armv7.apk');
      point('.dl-universal', 'fit-companion-universal.apk');
      if (main) document.querySelectorAll('.size').forEach((el) => (el.textContent = `${Math.round(main.size / 1048576)} MB`));
      document.getElementById('relLink').href = release.html_url;
      renderRelease();
    } catch (_) {
      document.getElementById('notes').innerHTML = `<p><a href="https://github.com/${REPO}/releases/latest">github.com/${REPO}/releases</a></p>`;
    }
  }

  applyLang(lang);
  loadRelease();
  onScroll();
})();
