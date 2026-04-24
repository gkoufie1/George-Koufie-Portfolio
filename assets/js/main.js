// ─── SCROLL FADE-IN ───
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry, i) => {
    if (entry.isIntersecting) {
      setTimeout(() => entry.target.classList.add('visible'), i * 80);
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.fade-up').forEach(el => observer.observe(el));

// ─── CONTACT FORM ───
document.getElementById('contact-form').addEventListener('submit', handleSubmit);

async function handleSubmit(e) {
  e.preventDefault();
  const btn = document.getElementById('submitBtn');
  const form = e.target;

  btn.textContent = 'Sending...';
  btn.disabled = true;

  try {
    const res = await fetch('https://formspree.io/f/xrerqowl', {
      method: 'POST',
      body: new FormData(form),
      headers: { 'Accept': 'application/json' }
    });

    if (res.ok) {
      btn.textContent = 'Message Sent ✓';
      btn.style.background = '#00a87a';
      btn.style.boxShadow = '0 0 30px rgba(0,168,122,0.5)';
      form.reset();
      setTimeout(() => {
        btn.textContent = 'Send Message →';
        btn.style.background = '';
        btn.style.boxShadow = '';
        btn.disabled = false;
      }, 3000);
    } else {
      btn.textContent = 'Failed — Try Again';
      btn.style.background = '#e03355';
      setTimeout(() => {
        btn.textContent = 'Send Message →';
        btn.style.background = '';
        btn.disabled = false;
      }, 3000);
    }
  } catch {
    btn.textContent = 'Failed — Try Again';
    btn.style.background = '#e03355';
    setTimeout(() => {
      btn.textContent = 'Send Message →';
      btn.style.background = '';
      btn.disabled = false;
    }, 3000);
  }
}
