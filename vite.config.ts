import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 3036,
  },
  plugins: [
    RubyPlugin(),
  ],
})
