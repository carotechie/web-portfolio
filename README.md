# Carolina Herrera Monteza - Personal Website

A professional website showcasing Carolina Herrera Monteza's expertise as a Senior DevOps Engineer with over 11 years of experience.

## Features

- **Responsive Design**: Optimized for all devices (desktop, tablet, mobile)
- **Bilingual Support**: English (primary) and Spanish languages
- **Modern UI**: Clean, professional design with Kiro purple theme
- **Performance Optimized**: Fast loading with optimized assets
- **SEO Friendly**: Proper meta tags and semantic HTML
- **Dockerized**: Ready for deployment with Docker

## Sections

- **Hero**: Introduction and social links
- **About**: Professional background and skills
- **Experience**: Career timeline and achievements
- **Speaking**: Conference topics and community involvement
- **Mentorship**: Mujeres IT program participation
- **Contact**: Professional contact information and blog link

## Technologies Used

- HTML5
- CSS3 (Custom properties, Grid, Flexbox)
- Vanilla JavaScript
- Font Awesome icons
- Google Fonts (Inter)
- Nginx (for serving)
- Docker & Docker Compose

## Local Development

### Prerequisites
- Docker and Docker Compose installed
- Modern web browser

### Running Locally

1. Clone the repository:
```bash
git clone <repository-url>
cd carolina-website
```

2. Build and run with Docker Compose:
```bash
docker-compose up --build
```

3. Open your browser and navigate to:
```
http://localhost
```

### Development without Docker

1. Serve the files using any local server:
```bash
# Using Python
python -m http.server 8000

# Using Node.js (if you have http-server installed)
npx http-server

# Using PHP
php -S localhost:8000
```

2. Open your browser and navigate to the local server URL.

## Deployment

### Docker Deployment

1. Build the Docker image:
```bash
docker build -t carolina-website .
```

2. Run the container:
```bash
docker run -d -p 80:80 --name carolina-website carolina-website
```

### Production Deployment

For production deployment, consider:

1. **SSL/TLS**: Use a reverse proxy like Traefik or Nginx Proxy Manager
2. **CDN**: Implement CloudFlare or similar for global content delivery
3. **Monitoring**: Add health checks and monitoring
4. **Backup**: Regular backups of the container and data

### Environment Variables

The Docker setup supports the following environment variables:

- `NGINX_HOST`: Domain name (default: carolinaherreramonteza.com)
- `NGINX_PORT`: Port number (default: 80)

## Blog Integration

The website includes links to `blog.carolinaherreramonteza.com`. To set up the blog:

1. Configure DNS to point the subdomain to your blog platform
2. Update the blog links in the HTML if using a different URL
3. Consider using platforms like:
   - Ghost
   - WordPress
   - Hugo/Jekyll with GitHub Pages
   - Medium custom domain

## Customization

### Colors
The website uses CSS custom properties for easy theming. Main colors are defined in `:root`:

```css
:root {
    --kiro-purple: #6366f1;
    --kiro-purple-dark: #4f46e5;
    --kiro-purple-light: #8b5cf6;
}
```

### Content
Update the content by modifying:
- `index.html`: Main content and structure
- `script.js`: Translations and interactive features
- `styles.css`: Styling and layout

### Languages
Add new languages by:
1. Extending the `translations` object in `script.js`
2. Adding new language buttons in the navigation
3. Adding corresponding `data-*` attributes to HTML elements

## Performance

The website is optimized for performance:
- Minified and compressed assets
- Lazy loading for images
- Efficient CSS and JavaScript
- Nginx gzip compression
- Browser caching headers

## Security

Security features included:
- Content Security Policy headers
- XSS protection
- Frame options
- Content type sniffing protection
- Hidden file access denial

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Contributing

This is a personal website. For suggestions or issues, please contact Carolina directly through her social media channels.

## License

© 2026 Carolina Herrera Monteza. All rights reserved.

## Contact

- **LinkedIn**: [carolinahm](https://www.linkedin.com/in/carolinahm)
- **Instagram**: [@carotechie](https://instagram.com/carotechie)
- **X (Twitter)**: [@carotechie](https://x.com/carotechie)
- **YouTube**: [TechconCarotechie](https://www.youtube.com/@TechconCarotechie)
- **Blog**: [blog.carolinaherreramonteza.com](https://blog.carolinaherreramonteza.com)# web-portfolio
# web-portfolio
