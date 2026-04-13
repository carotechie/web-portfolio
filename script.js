// Language switching functionality
const translations = {
    en: {
        // Navigation
        'Home': 'Home',
        'About': 'About',
        'Experience': 'Experience',
        'Speaking': 'Speaking',
        'Mentorship': 'Mentorship',
        'Contact': 'Contact',
        
        // Hero Section
        'Senior DevOps Engineer': 'Senior DevOps Engineer',
        'Transforming infrastructure with +11 years of experience': 'Transforming infrastructure with +11 years of experience',
        'Learn More': 'Learn More',
        'Read Blog': 'Read Blog',
        
        // About Section
        'About Me': 'About Me',
        
        // Experience Section
        'Experience Highlights': 'Experience Highlights',
        'Senior DevOps Engineer': 'Senior DevOps Engineer',
        'DevOps Engineer': 'DevOps Engineer',
        'Systems Administrator': 'Systems Administrator',
        
        // Speaking Section
        'Speaking & Community': 'Speaking & Community',
        'Cloud Infrastructure': 'Cloud Infrastructure',
        'DevOps Culture': 'DevOps Culture',
        'Women in Tech': 'Women in Tech',
        
        // Mentorship Section
        'Mentorship': 'Mentorship',
        'Mujeres IT Mentorship Program': 'Mujeres IT Mentorship Program',
        'Request Mentorship': 'Request Mentorship',
        'Mentees': 'Mentees',
        'Years Mentoring': 'Years Mentoring',
        'Countries Reached': 'Countries Reached',
        
        // Contact Section
        "Let's Connect": "Let's Connect",
        'Blog': 'Blog',
        
        // Footer
        'All rights reserved.': 'All rights reserved.'
    },
    es: {
        // Navigation
        'Home': 'Inicio',
        'About': 'Acerca',
        'Experience': 'Experiencia',
        'Speaking': 'Conferencias',
        'Mentorship': 'Mentoría',
        'Contact': 'Contacto',
        
        // Hero Section
        'Senior DevOps Engineer': 'Ingeniera DevOps Senior',
        'Transforming infrastructure with +11 years of experience': 'Transformando infraestructura con +11 años de experiencia',
        'Learn More': 'Conoce Más',
        'Read Blog': 'Lee el Blog',
        
        // About Section
        'About Me': 'Acerca de Mí',
        
        // Experience Section
        'Experience Highlights': 'Experiencia Destacada',
        'Senior DevOps Engineer': 'Ingeniera DevOps Senior',
        'DevOps Engineer': 'Ingeniera DevOps',
        'Systems Administrator': 'Administradora de Sistemas',
        
        // Speaking Section
        'Speaking & Community': 'Conferencias y Comunidad',
        'Cloud Infrastructure': 'Infraestructura en la Nube',
        'DevOps Culture': 'Cultura DevOps',
        'Women in Tech': 'Mujeres en Tecnología',
        
        // Mentorship Section
        'Mentorship': 'Mentoría',
        'Mujeres IT Mentorship Program': 'Programa de Mentoría Mujeres IT',
        'Request Mentorship': 'Solicitar Mentoría',
        'Mentees': 'Mentoreadas',
        'Years Mentoring': 'Años Mentoreando',
        'Countries Reached': 'Países Alcanzados',
        
        // Contact Section
        "Let's Connect": 'Conectemos',
        'Blog': 'Blog',
        
        // Footer
        'All rights reserved.': 'Todos los derechos reservados.'
    }
};

// Current language state
let currentLanguage = 'en';

// DOM elements
const langEnBtn = document.getElementById('lang-en');
const langEsBtn = document.getElementById('lang-es');
const hamburger = document.querySelector('.hamburger');
const navMenu = document.querySelector('.nav-menu');

// Language switching function
function switchLanguage(lang) {
    currentLanguage = lang;
    
    // Update button states
    langEnBtn.classList.toggle('active', lang === 'en');
    langEsBtn.classList.toggle('active', lang === 'es');
    
    // Update HTML lang attribute
    document.getElementById('html-root').setAttribute('lang', lang);
    
    // Update all elements with data attributes
    const elements = document.querySelectorAll('[data-en][data-es]');
    elements.forEach(element => {
        const text = element.getAttribute(`data-${lang}`);
        if (text) {
            element.textContent = text;
        }
    });
    
    // Store language preference
    localStorage.setItem('preferred-language', lang);
}

// Event listeners for language buttons
langEnBtn.addEventListener('click', () => switchLanguage('en'));
langEsBtn.addEventListener('click', () => switchLanguage('es'));

// Mobile menu toggle
hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('active');
    navMenu.classList.toggle('active');
});

// Close mobile menu when clicking on a link
document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', () => {
        hamburger.classList.remove('active');
        navMenu.classList.remove('active');
    });
});

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Navbar background on scroll
window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.style.background = 'rgba(255, 255, 255, 0.98)';
    } else {
        navbar.style.background = 'rgba(255, 255, 255, 0.95)';
    }
});

// Intersection Observer for animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
}, observerOptions);

// Add fade-in class to elements and observe them
document.addEventListener('DOMContentLoaded', () => {
    // Load saved language preference
    const savedLanguage = localStorage.getItem('preferred-language') || 'en';
    switchLanguage(savedLanguage);
    
    // Add animation classes to sections
    const sections = document.querySelectorAll('section');
    sections.forEach(section => {
        section.classList.add('fade-in');
        observer.observe(section);
    });
    
    // Add animation to timeline items
    const timelineItems = document.querySelectorAll('.timeline-item');
    timelineItems.forEach(item => {
        item.classList.add('fade-in');
        observer.observe(item);
    });
    
    // Add animation to cards
    const cards = document.querySelectorAll('.skill-item, .topic-card, .stat-item, .contact-link');
    cards.forEach(card => {
        card.classList.add('fade-in');
        observer.observe(card);
    });
});

// Mentorship button - now links directly to Mujeres IT
// No need for click handler as it's a proper external link

// Add typing effect to hero title
function typeWriter(element, text, speed = 100) {
    let i = 0;
    element.innerHTML = '';
    
    function type() {
        if (i < text.length) {
            element.innerHTML += text.charAt(i);
            i++;
            setTimeout(type, speed);
        }
    }
    
    type();
}

// Initialize typing effect when page loads
window.addEventListener('load', () => {
    const heroTitle = document.querySelector('.hero-title span');
    if (heroTitle) {
        const originalText = heroTitle.textContent;
        typeWriter(heroTitle, originalText, 80);
    }
});

// Add parallax effect to hero section
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const hero = document.querySelector('.hero');
    const rate = scrolled * -0.5;
    
    if (hero) {
        hero.style.transform = `translateY(${rate}px)`;
    }
});

// Add hover effects to social links
document.querySelectorAll('.social-links a').forEach(link => {
    link.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-5px) scale(1.1)';
    });
    
    link.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0) scale(1)';
    });
});

// Add click tracking for analytics (placeholder)
function trackClick(element, action) {
    // This would integrate with analytics services like Google Analytics
    console.log(`Tracked: ${action} - ${element}`);
}

// Track social media clicks
document.querySelectorAll('.social-links a, .contact-link').forEach(link => {
    link.addEventListener('click', function() {
        const platform = this.getAttribute('aria-label') || this.querySelector('span')?.textContent || 'Unknown';
        trackClick(platform, 'social_click');
    });
});

// Track navigation clicks
document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', function() {
        const section = this.getAttribute('href').replace('#', '');
        trackClick(section, 'navigation_click');
    });
});

// Add loading animation
window.addEventListener('load', () => {
    document.body.classList.add('loaded');
});

// Performance optimization: Lazy load images when implemented
function lazyLoadImages() {
    const images = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.remove('lazy');
                imageObserver.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
}

// Initialize lazy loading
document.addEventListener('DOMContentLoaded', lazyLoadImages);