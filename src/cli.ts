#!/usr/bin/env node
import { Command } from 'commander';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';
import ora from 'ora';
import { config } from 'dotenv';
import { textToSpeech } from './tts.js';
import { generateVideo } from './video-generator.js';

config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const program = new Command();

program
  .name('atenea')
  .description('AI Avatar Video Generator using SadTalker')
  .version('0.1.0');

program
  .command('generate')
  .description('Generate a talking head video from text input')
  .option('-i, --input <file>', 'Input text file', 'input.txt')
  .option('-a, --avatar <image>', 'Avatar image path', 'data/images/avatar.png')
  .option('-o, --output <file>', 'Output video path', 'output.mp4')
  .option('-v, --voice <voice>', 'TTS voice (nova, alloy, echo, etc.)', 'nova')
  .action(async (options) => {
    const spinner = ora();

    try {
      // Validate OpenAI API key
      if (!process.env.OPENAI_API_KEY) {
        console.error(
          chalk.red('❌ OPENAI_API_KEY not found in environment variables')
        );
        console.log(chalk.yellow('\nPlease create a .env file with:'));
        console.log(chalk.cyan("OPENAI_API_KEY='your-key-here'"));
        process.exit(1);
      }

      // Read input text
      spinner.start('Reading input text...');
      const inputPath = path.resolve(options.input);
      const inputText = await fs.readFile(inputPath, 'utf-8');
      spinner.succeed(`Input text loaded (${inputText.length} characters)`);

      // Validate avatar image
      const avatarPath = path.resolve(options.avatar);
      try {
        await fs.access(avatarPath);
        spinner.succeed(`Avatar image found: ${path.basename(avatarPath)}`);
      } catch {
        spinner.fail(`Avatar image not found: ${avatarPath}`);
        console.log(
          chalk.yellow('\nPlease add an avatar image (woman photo) to:')
        );
        console.log(chalk.cyan('data/images/avatar.png'));
        process.exit(1);
      }

      // Setup paths
      const audioDir = path.join(__dirname, '..', 'data', 'audio');
      const tempAudioPath = path.join(audioDir, 'temp.mp3'); // Will be replaced by hash-based name
      const videoPath = path.resolve(options.output);

      console.log(chalk.blue('\n🎬 Starting video generation\n'));

      // Generate audio from text (returns actual cached path)
      spinner.start('Generating speech from text...');
      process.env.TTS_VOICE = options.voice;
      const audioPath = await textToSpeech(inputText, tempAudioPath);
      spinner.succeed('Speech generated');

      // Generate video
      spinner.start(
        chalk.yellow(
          'Generating talking head video (this will take 8-15 minutes for 1-minute video)...'
        )
      );

      await generateVideo({
        imagePath: avatarPath,
        audioPath,
        outputPath: videoPath,
      });

      spinner.succeed('Video generated successfully!');

      console.log(chalk.green('\n✅ Success!\n'));
      console.log(chalk.cyan(`Video saved to: ${videoPath}`));
      console.log(chalk.cyan(`Audio saved to: ${audioPath}`));
      console.log(chalk.cyan(`\nOpen video: open "${videoPath}"`));
    } catch (error) {
      spinner.fail('Failed');
      console.error(chalk.red('\n❌ Error:'), error);
      process.exit(1);
    }
  });

program.parse();
