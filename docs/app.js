// Fit Companion website: language switch (EN / AR with RTL) + live "latest release" info from GitHub.
(() => {
  const REPO = 'MahdiHaf2410/fit-companion';
  const T = {
    ar: {
      navFeatures: 'المميزات', navAi: 'المدرب الذكي', navNew: 'الجديد', navInstall: 'التثبيت',
      download: 'تحميل', downloadApk: 'حمّل التطبيق (APK)', latest: 'آخر إصدار', seeFeatures: 'شوف المميزات',
      eyebrow: 'مجاني · أندرويد · العربية و English',
      h1a: 'تمرّن بذكاء.', h1b: 'كُل صحّي.', h1c: 'تابع كل شيء.',
      lead: 'رفيقك في الجيم والتغذية في تطبيق واحد: التمارين، حوالي 420 تمرين بفيديوهات شرح، تتبّع الأكل الجزائري، صور التقدّم ومدرب ذكي بالذكاء الاصطناعي (Gemini).',
      otherBuilds: 'تلفون قديم؟', armv7: 'نسخة 32-بت', universal: 'نسخة شاملة (كل التلفونات)',
      mGood: 'مساء الخير', mPush: 'يوم الدفع', mWater: 'الماء', fAi: 'خطة الوجبات جاهزة', fPr: 'رقم قياسي جديد: 100 كغ',
      sEx: 'تمرين', sThemes: 'ثيم', sAi: 'مدرب Gemini', sLang: 'لغتين (ع · EN)',
      featTitle: 'كل اللي تحتاجو، في تطبيق واحد', featSub: 'يخدم بلا إنترنت. بياناتك تبقى في تلفونك، مع نسخة سحابية مجانية اختيارية.',
      f1t: 'التمارين', f1d: 'ابنِ برامجك بنفسك، سجّل المجموعات مع RPE والسوبرسيت والدروب سيت، مؤقت الراحة في الإشعارات، كشف الأرقام القياسية واقتراح زيادة الوزن.',
      f2t: 'أكثر من 420 تمرين بالفيديو', f2d: 'كل العضلات من الصدر حتى الرقبة بأسماء عربية، فلترة حسب المعدات، وفيديو شرح داخل التطبيق لكل تمرين.',
      f3t: 'التغذية', f3d: 'أكل جزائري ومغاربي، ماسح الباركود، تحليل صورة الوجبة بالذكاء الاصطناعي، تسجيل الأكل بالصوت بالدارجة، وصفات وTDEE ذكي.',
      f4t: 'التقدّم', f4d: 'منحنيات الوزن ونسبة الدهون، القياسات، صور قبل وبعد مع تحليل التقدّم بالذكاء الاصطناعي، والنوم وتأثيرو على الأداء.',
      f5t: 'التحديات والأصدقاء', f5d: 'تحديات أسبوعية وشهرية، مستويات XP من مبتدئ حتى أسطورة، ترتيب مع الأصدقاء وكروت للمشاركة.',
      f6t: '20 ثيم', f6d: 'فاتح وداكن، كل واحد بأشكالو وخلفية متحركة تتفاعل مع اللمس. دعم كامل للعربية من اليمين لليسار.',
      aiTitle: 'مدرب ذكي يعرف بياناتك', aiSub: 'نبعثو ملخصات قصيرة برك، عمرنا ما نبعثو اسمك ولا إيميلك. الصور والصوت ما يتحفظوش.',
      ai1: 'تقرير أسبوعي بنقطة وأهداف للأسبوع الجاي', ai2: 'بناء برنامج بتمارين التطبيق برك', ai3: 'خطة وجبات ليوم كامل بأكل محلي وقائمة مشتريات',
      ai4: 'صوّر وجبتك ← العناصر والغرامات والماكروز', ai5: 'قول واش كليت بالدارجة ← يتسجّل', ai6: 'دردشة مع المدرب تقبل الصور والفيديو',
      ai7: 'كشف التعب وأسبوع التخفيف، وملاحظات مباشرة أثناء التمرين',
      c1: 'قيّم أسبوعي 💪', c2: '4 حصص، رقمين قياسيين والبروتين مضبوط 5 من 7 أيام. الأسبوع الجاي: زيد مجموعة للأرجل ونام 7 ساعات وأكثر.',
      c3: '🎤 "زوج بيضات، كسرة وقهوة بالحليب"', c4: 'تسجّلو 3 عناصر · 512 سعرة · بروتين 24 غ ✓',
      newTitle: 'الجديد في', released: 'صدر في', allReleases: 'كل الإصدارات', loading: 'جاري التحميل…',
      instTitle: 'التثبيت في 3 خطوات',
      st1t: 'حمّل', st1d: 'اضغط "حمّل التطبيق". أغلب التلفونات الحديثة تحتاج النسخة الرئيسية.',
      st2t: 'اسمح بالتثبيت', st2d: 'أندرويد يطلب مرة وحدة السماح بالتثبيت من المتصفح ولا من الملفات. اسمح.',
      st3t: 'افتح وتمرّن', st3d: 'التحديثات تتثبت فوق النسخة القديمة وبياناتك تبقى. غير حمّل الـ APK الجديد من هاذ الصفحة.',
      faqTitle: 'أسئلة',
      q1: 'هل التطبيق مجاني؟', a1: 'إيه. التطبيق، النسخة السحابية وأدوات الذكاء الاصطناعي مجانيين (مع حد يومي معقول للذكاء الاصطناعي).',
      q2: 'هل بياناتي محمية؟', a2: 'كلش يتحفظ في تلفونك. الحساب السحابي الاختياري محمي وحتى واحد ما يقرا بياناتك غيرك، والأصدقاء يشوفو غير شوية إحصائيات.',
      q3: 'واش من تلفونات يخدم عليهم؟', a3: 'أندرويد 8.0 وما فوق. ما كاينش نسخة آيفون حالياً.',
      q4: 'يخدم بلا إنترنت؟', a4: 'إيه. التمارين، تسجيل الأكل والتقدّم يخدمو بلا إنترنت. الذكاء الاصطناعي، الفيديوهات، الباركود والمزامنة يحتاجو إنترنت.',
      q5: 'أندرويد يقول التطبيق غير معروف. هل هو آمن؟', a5: 'التطبيق يتثبت من خارج Play Store، لهذا أندرويد ينبّهك. الكود المصدري متاح للجميع على GitHub.',
      dev: 'تصميم وتطوير', devName: 'حفيان المهدي',
    },
  };

  // ---------- language ----------
  const en = {};
  document.querySelectorAll('[data-i18n]').forEach((el) => (en[el.dataset.i18n] = el.textContent));
  const btn = document.getElementById('langBtn');
  let lang = 'en';
  try {
    lang = localStorage.getItem('fc_lang') || ((navigator.language || '').startsWith('ar') ? 'ar' : 'en');
  } catch (_) {}

  function apply(l) {
    lang = l;
    const dict = l === 'ar' ? T.ar : en;
    document.documentElement.lang = l;
    document.documentElement.dir = l === 'ar' ? 'rtl' : 'ltr';
    document.querySelectorAll('[data-i18n]').forEach((el) => {
      const v = dict[el.dataset.i18n];
      if (v) el.textContent = v;
    });
    btn.textContent = l === 'ar' ? 'EN' : 'ع';
    try { localStorage.setItem('fc_lang', l); } catch (_) {}
    renderNotes();
  }
  btn.addEventListener('click', () => apply(lang === 'ar' ? 'en' : 'ar'));

  // ---------- latest release ----------
  let release = null;
  const esc = (s) => s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const md = (s) => esc(s).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

  function renderNotes() {
    const box = document.getElementById('notes');
    if (!release) return;
    const body = release.body || '';
    const parts = body.split('<!-- ar -->');
    const text = (lang === 'ar' && parts[1] ? parts[1] : parts[0]).trim();
    const items = text.split('\n').map((l) => l.trim()).filter((l) => l.startsWith('- ')).map((l) => `<li>${md(l.slice(2))}</li>`);
    box.innerHTML = items.length ? `<ul>${items.join('')}</ul>` : `<p>${md(text)}</p>`;
    const d = new Date(release.published_at);
    document.getElementById('relDate').textContent = d.toLocaleDateString(lang === 'ar' ? 'ar-DZ' : 'en-GB', { year: 'numeric', month: 'long', day: 'numeric' });
  }

  async function loadRelease() {
    try {
      const res = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`, { headers: { Accept: 'application/vnd.github+json' } });
      if (!res.ok) throw new Error(res.status);
      release = await res.json();
      const tag = release.tag_name;
      document.querySelectorAll('.ver').forEach((el) => (el.textContent = tag));
      const asset = (n) => (release.assets || []).find((a) => a.name === n);
      const set = (sel, name) => {
        const a = asset(name);
        if (a) document.querySelectorAll(sel).forEach((el) => (el.href = a.browser_download_url));
        return a;
      };
      const main = set('.dl-main', 'fit-companion-arm64.apk');
      set('.dl-armv7', 'fit-companion-armv7.apk');
      set('.dl-universal', 'fit-companion-universal.apk');
      if (main) document.querySelectorAll('.size').forEach((el) => (el.textContent = `${Math.round(main.size / 1048576)} MB`));
      document.getElementById('relLink').href = release.html_url;
      renderNotes();
    } catch (_) {
      // Offline or rate-limited: the buttons still point to /releases/latest/download/… (always the newest APK).
      const box = document.getElementById('notes');
      box.innerHTML = `<p><a href="https://github.com/${REPO}/releases/latest" target="_blank" rel="noopener">github.com/${REPO}/releases</a></p>`;
    }
  }

  // ---------- reveal on scroll ----------
  const io = 'IntersectionObserver' in window
    ? new IntersectionObserver((entries) => entries.forEach((e) => e.isIntersecting && (e.target.classList.add('in'), io.unobserve(e.target))), { threshold: 0.12 })
    : null;
  document.querySelectorAll('.card, .step, .stats > div, .chat, .faq details').forEach((el) => {
    if (!io) return;
    el.classList.add('reveal');
    io.observe(el);
  });

  apply(lang);
  loadRelease();
})();
