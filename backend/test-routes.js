const express = require('express');

console.log('Testing route loading...\n');

try {
    const authRoutes = require('./routes/auth');
    console.log('✓ Auth routes loaded');
    console.log('Type:', typeof authRoutes);
    console.log('Stack:', authRoutes.stack ? authRoutes.stack.length + ' routes' : 'No stack');
} catch (error) {
    console.error('✗ Auth routes error:', error.message);
}

process.exit(0);
