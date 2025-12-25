import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { AuthProvider } from '@/hooks/useAuth';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: {
    default: 'Social Live - Creator Dashboard',
    template: '%s | Social Live',
  },
  description: 'Professional dashboard for content creators and administrators on Social Live platform',
  keywords: ['social media', 'creator dashboard', 'analytics', 'content management'],
  authors: [{ name: 'Social Live Team' }],
  creator: 'Social Live',
  publisher: 'Social Live',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL('https://dashboard.sociallive.com'),
  alternates: {
    canonical: '/',
  },
  openGraph: {
    title: 'Social Live - Creator Dashboard',
    description: 'Professional dashboard for content creators and administrators',
    url: 'https://dashboard.sociallive.com',
    siteName: 'Social Live Dashboard',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Social Live Dashboard',
      },
    ],
    locale: 'en_US',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Social Live - Creator Dashboard',
    description: 'Professional dashboard for content creators and administrators',
    images: ['/og-image.jpg'],
  },
  robots: {
    index: false, // Dashboard should not be indexed
    follow: false,
    nocache: true,
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}