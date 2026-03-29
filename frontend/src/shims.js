// Browser shim for Node.js modules
import { resolve, dirname, basename, extname, join, isAbsolute, relative, normalize } from 'node:path'
import { fileURLToPath } from 'node:url'

// Make these available globally for rollup
window.__dirname = dirname(fileURLToPath(import.meta.url))
window.__filename = fileURLToPath(import.meta.url)
