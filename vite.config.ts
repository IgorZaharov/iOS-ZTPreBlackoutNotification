import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import fs from 'fs';
import path from 'path';
import {defineConfig} from 'vite';

function readBuildVersion(): string {
  try {
    const projectYml = fs.readFileSync(path.resolve(process.cwd(), 'ios/project.yml'), 'utf-8');
    const iosMatch = projectYml.match(/MARKETING_VERSION:\s*"([0-9]+\.[0-9]+\.[0-9]+)"/);
    if (iosMatch && iosMatch[1]) {
      return iosMatch[1];
    }
  } catch {
    // Fallback to Android gradle or 1.3.3
  }
  try {
    const gradleContent = fs.readFileSync(path.resolve(process.cwd(), 'android/app/build.gradle.kts'), 'utf-8');
    const match = gradleContent.match(/versionName\s*=.*?"([0-9]+\.[0-9]+\.[0-9]+)"/);
    if (match && match[1]) {
      return match[1];
    }
  } catch {
    // Fallback
  }
  return '1.3.3';
}

export default defineConfig(() => {
  const appVersion = readBuildVersion();
  const port = 3000;
  return {
    plugins: [react(), tailwindcss()],
    define: {
      __APP_VERSION__: JSON.stringify(appVersion),
    },
    resolve: {
      alias: {
        '@': path.resolve(process.cwd(), '.'),
      },
    },
    server: {
      port,
      host: '0.0.0.0',
      allowedHosts: true,
      // HMR is disabled in AI Studio via DISABLE_HMR env var.
      // Do not modify—file watching is disabled to prevent flickering during agent edits.
      hmr: process.env.DISABLE_HMR !== 'true',
      // Disable file watching when DISABLE_HMR is true to save CPU during agent edits.
      watch: process.env.DISABLE_HMR === 'true' ? null : {},
      proxy: {
        '/proxy-ztoe': {
          target: 'https://www.ztoe.com.ua',
          changeOrigin: true,
          secure: false,
          rewrite: (p) => p.replace(/^\/proxy-ztoe/, '')
        }
      }
    },
    preview: {
      port,
      host: '0.0.0.0',
      allowedHosts: true,
    },
  };
});
