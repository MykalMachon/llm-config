#!/usr/bin/env node

import { spawn, execSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import puppeteer from "puppeteer-core";

const useProfile = process.argv[2] === "--profile";

if (process.argv[2] && process.argv[2] !== "--profile") {
	console.log("Usage: start.js [--profile]");
	console.log("\nOptions:");
	console.log(
		"  --profile  Copy your default Chrome profile (cookies, logins)",
	);
	console.log("\nExamples:");
	console.log("  start.js            # Start with fresh profile");
	console.log("  start.js --profile  # Start with your Chrome profile");
	process.exit(1);
}

// Detect platform and WSL
const platform = process.platform;
const isWSL = platform === "linux" && existsSync("/proc/version") &&
	readFileSync("/proc/version", "utf8").toLowerCase().includes("microsoft");

// Find Chrome binary based on platform
function findChromeBinary() {
	if (platform === "darwin") {
		return "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
	}

	// Linux/WSL - try common locations
	const linuxPaths = [
		"/usr/bin/google-chrome",
		"/usr/bin/google-chrome-stable",
		"/usr/bin/chromium",
		"/usr/bin/chromium-browser",
		"/snap/bin/chromium",
	];

	for (const path of linuxPaths) {
		if (existsSync(path)) {
			return path;
		}
	}

	throw new Error(
		"Chrome/Chromium not found. Please install google-chrome or chromium.",
	);
}

// Get default profile directory based on platform
function getDefaultProfileDir() {
	if (platform === "darwin") {
		return `${process.env["HOME"]}/Library/Application Support/Google/Chrome/`;
	}

	// Linux/WSL
	const configHome = process.env["XDG_CONFIG_HOME"] || `${process.env["HOME"]}/.config`;
	const googleChrome = `${configHome}/google-chrome/`;
	const chromium = `${configHome}/chromium/`;

	if (existsSync(googleChrome)) {
		return googleChrome;
	}
	if (existsSync(chromium)) {
		return chromium;
	}

	return googleChrome; // default to google-chrome even if doesn't exist
}

// Kill existing Chrome/Chromium processes
try {
	if (platform === "darwin") {
		execSync("killall 'Google Chrome'", { stdio: "ignore" });
	} else {
		// Linux/WSL - try both chrome and chromium
		try {
			execSync("killall chrome", { stdio: "ignore" });
		} catch { }
		try {
			execSync("killall chromium", { stdio: "ignore" });
		} catch { }
		try {
			execSync("killall chromium-browser", { stdio: "ignore" });
		} catch { }
	}
} catch { }

// Wait a bit for processes to fully die
await new Promise((r) => setTimeout(r, 1000));

// Setup profile directory
execSync("mkdir -p ~/.cache/scraping", { stdio: "ignore" });

if (useProfile) {
	const defaultProfile = getDefaultProfileDir();
	if (existsSync(defaultProfile)) {
		// Sync profile with rsync (much faster on subsequent runs)
		execSync(
			`rsync -a --delete "${defaultProfile}" ~/.cache/scraping/`,
			{ stdio: "pipe" },
		);
		console.log(`Copied profile from: ${defaultProfile}`);
	} else {
		console.log(`Warning: Default profile not found at ${defaultProfile}`);
	}
}

// Build Chrome arguments
const chromeBinary = findChromeBinary();
const chromeArgs = [
	"--remote-debugging-port=9222",
	`--user-data-dir=${process.env["HOME"]}/.cache/scraping`,
	"--profile-directory=Default",
];

// Add --no-sandbox for WSL (required due to kernel limitations)
if (isWSL) {
	chromeArgs.push("--no-sandbox");
	console.log("Detected WSL - adding --no-sandbox flag");
}

// Start Chrome in background (detached so Node can exit)
spawn(chromeBinary, chromeArgs, { detached: true, stdio: "ignore" }).unref();

// Wait for Chrome to be ready by attempting to connect
let connected = false;
for (let i = 0; i < 30; i++) {
	try {
		const browser = await puppeteer.connect({
			browserURL: "http://localhost:9222",
			defaultViewport: null,
		});
		await browser.disconnect();
		connected = true;
		break;
	} catch {
		await new Promise((r) => setTimeout(r, 500));
	}
}

if (!connected) {
	console.error("✗ Failed to connect to Chrome");
	process.exit(1);
}

console.log(
	`✓ Chrome started on :9222${useProfile ? " with your profile" : ""}`,
);