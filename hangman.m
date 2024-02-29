
function simple_hangman
    % Word list defined as a cell array
    word_list = {
         "ELEPHANT", "GIRAFFE", "TIGER", "PENGUIN", "KANGAROO", "DOLPHIN", "CROCODILE", "ZEBRA",...
         "AUSTRALIA", "CANADA", "BRAZIL", "FRANCE", "JAPAN", "EGYPT", "MEXICO", "INDIA",...
         "HAPPY", "SAD", "EXCITED", "ANXIOUS", "LOVE", "ANGRY", "SURPRISED", "CONFUSED",...
        "TEACHER", "DOCTOR", "ENGINEER", "ARTIST", "ATHLETE", "SCIENTIST", "MUSICIAN", "WRITER",...
         "BIRD", "MALL", "MEAL", "DISK", "OVEN", "POET", "ROAD", "HALL", "EXAM", "FACT",...
         "KING", "WEEK", "UNIT", "SOUP", "GATE", "BATH", "HAIR", "MOOD", "WOOD", "LOVE",...
         "CELL", "MENU", "LOSS", "MODE", "ARMY", "TOWN", "FOOD", "ROLE", "DATA", "MATH",...
         "BEER", "CITY", "GIRL", "AREA", "LAKE", "DESK", "SONG", "YEAR", "WIFE", "USER",...
         "LADY", "GOAL"
    }; 
    % Initialize game variables
    wordIndex = randi(length(word_list)); % Random index from word_list
    wordToGuess = char(word_list{wordIndex}); % The word the player has to guess
    % wordToGuess = 'BOOK'; % Example word
    wordDisplay = repmat('_ ', 1, length(wordToGuess)); % Two characters for every letter: an underscore and a space
    maxAttempts = 5; % Maximum wrong attempts allowed
    attemptsLeft = maxAttempts; % Remaining attempts
    normalizedColor = [171/255, 216/255, 212/255];
    topMargin = 50; % Pixels for top margin

    % Setup the UI
    screenSize = get(0, 'ScreenSize'); % Gets the size of your screen
    figWidth = 600;
    figHeight = screenSize(4) * 0.6; % 80% of screen height
    figurePosition = [(screenSize(3)-figWidth)/2, (screenSize(4)-figHeight)/2, figWidth, figHeight];
    hFig = uifigure( 'Position', figurePosition,'Color', normalizedColor);
    hFig.Name = 'Hangman Game';

    % Positioning calculations
    imageHeight = figHeight * 0.4; % Adjust image height as per GUI requirements
    imageWidth = imageHeight; % Keep the image aspect ratio square
    leftPosition = (figWidth - imageWidth) / 2; % Center the image horizontally
    bottomPosition = figHeight - imageHeight - topMargin; % Position image from the top with margin
    
    % UI Components
    hImg = uiimage(hFig, ...
                   'Position', [leftPosition, bottomPosition, imageWidth, imageHeight], ...
                   'ImageSource', 'hangman0.png', ...
                   'ScaleMethod', 'fill');

    hTxt = uilabel(hFig, ...
                   'Position', [leftPosition, bottomPosition - 50, imageWidth, 50], ...
                   'Text', wordDisplay, ...
                   'FontSize',28, ...
                   'HorizontalAlignment', 'center');

        % Setup the Key Pressed Callback for the figure
    hFig.KeyPressFcn = @figure_keypress;

    % Alphabet buttons
    btnSize = [30, 30];
    startX = (figWidth - (btnSize(1) * 13 + 5 * 12)) / 2; % Center align buttons
    startY = 50; % Distance from the bottom of the figure
    btn = gobjects(1, 26); % Preallocate button objects
    for i = 1:26
        row = floor((i-1) / 13);
        col = mod(i-1, 13);
        x = startX + (col * (btnSize(1) + 5));
        y = startY + (row * (btnSize(2) + 5));
        letter = char(64 + i);
        btn(i) = uibutton(hFig, ...
                  'Text', letter, ...
                  'Position', [x, y, btnSize(1), btnSize(2)], ...
                  'ButtonPushedFcn', {@button_callback, letter});
    end

    % Nested Callback Functions
     function button_callback(src, ~, letter)
      guessedIndices = strfind(wordToGuess, letter); % Find all occurrences of the guessed letter
       if ~isempty(guessedIndices)
        for idx = guessedIndices
            wordDisplay((idx-1)*2 + 1) = letter; % Replace only the underscore with the letter
        end
        hTxt.Text = wordDisplay; % Update display label
    else
        attemptsLeft = attemptsLeft - 1; % Decrement attempts left
        updateHangmanImage(); % Update hangman image
    end
    src.Enable = 'off'; % Disable the pressed button
    checkGameEnd(); % Check if the game has ended
end
    
    function updateHangmanImage()
        hImg.ImageSource = ['hangman', num2str(maxAttempts + 1 - attemptsLeft), '.png'];
    end
    
    function disableAllButtons()
        for i = 1:26
            btn(i).Enable = 'off';
        end
    end
    
    function playLoseSound()
        [y, Fs] = audioread('lose_sound.wav'); % Load the sound file
        sound(y, Fs); % Play the sound
    end
    
    function playWinSound()
        [y, Fs] = audioread('win_sound.wav'); % Load the sound file
        sound(y, Fs); % Play the sound
    end
     % Trigger the restart when the 'r' key is released
    function figure_keypress(src, event)
      if strcmp(event.Key, 'r') % Check if 'r' key was released
         restartGame(); % Call the function to restart the game
       end
    end
    function checkGameEnd()
        if attemptsLeft == 0
            uialert(hFig, ['You lost! The word was: ', wordToGuess], 'Game Over');
            disableAllButtons();
            playLoseSound();
        elseif ~contains(wordDisplay, '_')
            uialert(hFig, 'Congratulations! You won!', 'Victory');
            disableAllButtons();
            playWinSound();
        end
    end

    function restartGame()
    % Reset the game state
    wordIndex = randi(length(word_list)); % Random index from word_list
    wordToGuess = char(word_list{wordIndex}); % The word the player has to guess
    wordDisplay = repmat('_ ', 1, length(wordToGuess)); % Two characters for every letter: an underscore and a space
    attemptsLeft = maxAttempts; % Reset remaining attempts
    
    % Reset the UI components
    hTxt.Text = wordDisplay; % Update display label
    hImg.ImageSource = 'hangman0.png'; % Reset hangman image to the initial state
    
    % Re-enable all alphabet buttons
    for i = 1:length(btn)
        btn(i).Enable = 'on';
    end
end
end