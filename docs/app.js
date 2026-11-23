// Fit Companion site: Arabic/English switch (with RTL) and the latest release read from GitHub,
// so the download buttons, version and change list follow every new release automatically.
(() => {
  const REPO = 'MahdiHaf2410/fit-companion';
  const AR = {
    skip: 'انتقل إلى المحتوى',
    navInside: 'محتوى التطبيق', navCoach: 'المدرب', navChanges: 'آخر تحديث', navInstall: 'التثبيت',
    h1: 'سجّل التمرين. غذِّ عضلاتك. وشوف الأرقام تطلع.',
    lead: 'Fit Companion هو سجل تمارين، ومفكرة أكل، ومدرب، في تطبيق أندرويد واحد. يخدم بلا إنترنت، يهدر بالعربية والإنجليزية، ويعرف واش هي الكسرة والشوربة.',
    download: 'حمّل للأندرويد', version: 'الإصدار', free: 'مجاني وبلا إشهار.',
    barCaption: 'هي 20 كغ تاع البار وأربع أقراص في كل جهة. التطبيق يحسبها عليك، ويحسب كل تكرار ترفعو.',
    insideTitle: 'واش كاين في التطبيق', insideIntro: 'التطبيق فيه أربع خانات. هذا واش تديرلك كل وحدة.',
    t1: 'التمارين', t1p: 'ابنِ برامجك بنفسك ولا ابدا من برنامج جاهز، وسجّل كل مجموعة وأنت تتمرّن. مؤقت الراحة يبان في الإشعارات، والتطبيق يكتشف أرقامك القياسية ويقولك وقتاش تزيد الوزن.',
    t1a: '420 تمرين بأسماء عربية وفيديو شرح لكل واحد', t1b: 'سوبرسيت، دروب سيت، إحماء ومستوى المجهود (RPE)', t1c: 'ينبّهك كي يجي وقت أسبوع خفيف',
    t2: 'التغذية', t2p: 'سجّل وجباتك من قائمة فيها الأكل الجزائري، امسح الباركود، ولا صوّر صحنك وخلّي الذكاء الاصطناعي يحسبو. وتقدر غير تقول واش كليت.',
    t2a: 'السعرات والبروتين والنشويات والدهون مقارنة بهدفك', t2b: 'سعراتك الحقيقية للثبات، محسوبة من تطوّر وزنك', t2c: 'تتبّع الماء وتذكير بالوجبات',
    t3: 'التقدّم', t3p: 'الوزن ونسبة الدهون والقياسات في منحنيات واضحة، وصور قبل وبعد تقارنهم جنب بعض. اربط Health Connect وشوف كيفاش النوم يأثّر على تمرينك.',
    t3a: 'تحديات أسبوعية وشهرية ومستويات توصلّها', t3b: 'ترتيب مع الأصدقاء اللي تضيفهم برمز', t3c: 'شارك تمرين ولا مستوى كصورة',
    t4: 'المدرب', t4p: 'اسأل المدرب على تمرينك ولا أكلك، ومعاها صورة ولا فيديو إذا لزم. يقرا ملخص قصير لأرقامك برك، عمرو ما يشوف اسمك ولا إيميلك.',
    t4a: 'تقرير أسبوعي بنقطة وثلاث أهداف', t4b: 'برنامج مبني من تمارين التطبيق', t4c: 'نهار كامل من الوجبات يناسب أهدافك، مع قائمة المشتريات',
    coachTitle: 'مدرب قرا سجلك', coachP: 'أغلب التطبيقات تعطيك نفس النصائح اللي تعطيها للناس الكل. هذا يجاوبك من أسبوعك أنت: واش رفعت، واش كليت وكيفاش رقدت.',
    c1: 'كيفاش كان أسبوعي؟', c2a: '8.5 من 10.', c2b: 'أربع حصص، رقمين قياسيين جداد، والبروتين كافي في خمس أيام. الأسبوع الجاي زيد مجموعة في يوم الأرجل وحاول ترقد سبع ساعات.',
    c3: 'زوج بيضات، طرف كسرة وقهوة بالحليب.', c4: 'تزادو ثلاث عناصر للفطور: 512 سعرة و24 غ بروتين.',
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

  // ---------- language ----------
  const EN = {};
  document.querySelectorAll('[data-i18n]').forEach((el) => (EN[el.dataset.i18n] = el.textContent));
  const btn = document.getElementById('langBtn');
  let lang = 'en';
  try {
    lang = localStorage.getItem('fc_lang') || ((navigator.language || '').toLowerCase().startsWith('ar') ? 'ar' : 'en');
  } catch (_) {}

  function apply(l) {
    lang = l;
    const dict = l === 'ar' ? AR : EN;
    document.documentElement.lang = l;
    document.documentElement.dir = l === 'ar' ? 'rtl' : 'ltr';
    document.querySelectorAll('[data-i18n]').forEach((el) => {
      const v = dict[el.dataset.i18n];
      if (v) el.textContent = v;
    });
    btn.textContent = l === 'ar' ? 'English' : 'العربية';
    btn.lang = l === 'ar' ? 'en' : 'ar';
    try { localStorage.setItem('fc_lang', l); } catch (_) {}
    renderRelease();
  }
  btn.addEventListener('click', () => apply(lang === 'ar' ? 'en' : 'ar'));

  // ---------- latest release ----------
  let release = null;
  const esc = (s) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const inline = (s) => esc(s).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

  function renderRelease() {
    if (!release) return;
    const parts = (release.body || '').split('<!-- ar -->');
    const text = (lang === 'ar' && parts[1] ? parts[1] : parts[0]).trim();
    const items = text.split('\n').map((l) => l.trim()).filter((l) => l.startsWith('- ')).map((l) => `<li>${inline(l.slice(2))}</li>`);
    document.getElementById('notes').innerHTML = items.length ? `<ul>${items.join('')}</ul>` : `<p>${inline(text)}</p>`;
    const d = new Date(release.published_at);
    const t = document.getElementById('relDate');
    t.dateTime = release.published_at;
    t.textContent = d.toLocaleDateString(lang === 'ar' ? 'ar-DZ' : 'en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  }

  async function loadRelease() {
    try {
      const res = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, { headers: { Accept: 'application/vnd.github+json' } });
      if (!res.ok) throw new Error(String(res.status));
      release = await res.json();
      const version = release.tag_name.replace(/^v/, '');
      document.querySelectorAll('.ver').forEach((el) => (el.textContent = version));
      const asset = (name) => (release.assets || []).find((a) => a.name === name);
      const point = (selector, name) => {
        const a = asset(name);
        if (a) document.querySelectorAll(selector).forEach((el) => (el.href = a.browser_download_url));
        return a;
      };
      const main = point('.dl-main', 'fit-companion-arm64.apk');
      point('.dl-armv7', 'fit-companion-armv7.apk');
      point('.dl-universal', 'fit-companion-universal.apk');
      if (main) document.querySelectorAll('.size').forEach((el) => (el.textContent = `${Math.round(main.size / 1048576)} MB`));
      document.getElementById('relLink').href = release.html_url;
      renderRelease();
    } catch (_) {
      // Offline or rate limited: the buttons already point at /releases/latest/download/…, which is always the newest file.
      document.getElementById('notes').innerHTML =
        `<p><a href="https://github.com/${REPO}/releases/latest">github.com/${REPO}/releases</a></p>`;
    }
  }

  apply(lang);
  loadRelease();
})();
