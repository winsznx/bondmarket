/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    transpilePackages: ['@bondmarket/shared', '@bondmarket/base-adapter', '@bondmarket/stacks-adapter'],
};

export default nextConfig;
