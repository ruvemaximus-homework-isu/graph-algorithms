import re
import os
import math
import random

# Константы
ROWS = 6
COLS = 7
PLAYER = 1
AI = 2
EMPTY = 0
ALPHA_BETA_DEPTH = int(os.getenv("ALPHA_BETA_DEPTH", 5))

GET_INPUT_COLUMN_REGEX = re.compile(r"\d")

# Цвета
YELLOW_BOLD = "\033[93m\033[1m"
BLUE = "\033[94m"  # Синий для игрока
RED = "\033[91m"  # Красный для ИИ
GRAY = "\033[90m"  # Серый для пустых клеток
RESET = "\033[0m"  # Сброс цвета


def create_board():
    """Создает пустую доску."""
    return [[EMPTY for _ in range(COLS)] for _ in range(ROWS)]


def is_valid_location(board, col):
    """Проверяет, можно ли сделать ход в колонку col."""
    return board[0][col] == EMPTY


def get_next_open_row(board, col):
    """Находит следующую доступную строку в колонке col."""
    for r in range(ROWS - 1, -1, -1):
        if board[r][col] == EMPTY:
            return r


def drop_piece(board, row, col, piece):
    """Размещает фишку piece в указанной ячейке."""
    board[row][col] = piece


def print_board(board):
    """Печатает доску в консоль с цветными символами."""

    for row in board:
        for cell in row:
            if cell == PLAYER:
                print(f"{BLUE}*{RESET}", end=" ")
            elif cell == AI:
                print(f"{RED}*{RESET}", end=" ")
            else:
                print(f"{GRAY}.{RESET}", end=" ")
        print()

    for i in range(COLS):
        print(i, end=" ")
    print()


def winning_move(board, piece):
    """Проверяет, есть ли выигрышный ход для игрока piece."""
    # Проверка по горизонтали
    for r in range(ROWS):
        for c in range(COLS - 3):
            if all(board[r][c + i] == piece for i in range(4)):
                return True
    # Проверка по вертикали
    for r in range(ROWS - 3):
        for c in range(COLS):
            if all(board[r + i][c] == piece for i in range(4)):
                return True
    # Проверка по диагонали (слева-направо)
    for r in range(ROWS - 3):
        for c in range(COLS - 3):
            if all(board[r + i][c + i] == piece for i in range(4)):
                return True
    # Проверка по диагонали (справа-налево)
    for r in range(ROWS - 3):
        for c in range(3, COLS):
            if all(board[r + i][c - i] == piece for i in range(4)):
                return True
    return False


def is_terminal_node(board):
    """Проверяет, является ли текущее состояние финальным."""
    return (
        winning_move(board, PLAYER)
        or winning_move(board, AI)
        or all(not is_valid_location(board, c) for c in range(COLS))
    )


def evaluate_window(window, piece: PLAYER | AI):
    """Оценивает группу из 4 ячеек."""
    score = 0
    opp_piece = PLAYER if piece == AI else AI

    piece_count = window.count(piece)
    empty_count = window.count(EMPTY)

    if piece_count == 4:
        score += 100
    elif piece_count == 3 and empty_count == 1:
        score += 5
    elif piece_count == 2 and empty_count == 2:
        score += 2
    if window.count(opp_piece) == 3 and empty_count == 1:
        score -= 4

    return score


def score_position(board, piece):
    """Оценивает текущую позицию для игрока piece."""
    score = 0

    # Центральная колонка
    center_array = [board[r][COLS // 2] for r in range(ROWS)]
    center_count = center_array.count(piece)
    score += center_count * 3

    # Горизонтальные оценки
    for r in range(ROWS):
        row_array = board[r]
        for c in range(COLS - 3):
            window = row_array[c : c + 4]
            score += evaluate_window(window, piece)

    # Вертикальные оценки
    for c in range(COLS):
        col_array = [board[r][c] for r in range(ROWS)]
        for r in range(ROWS - 3):
            window = col_array[r : r + 4]
            score += evaluate_window(window, piece)

    # Диагонали
    for r in range(ROWS - 3):
        for c in range(COLS - 3):
            window = [board[r + i][c + i] for i in range(4)]
            score += evaluate_window(window, piece)

    for r in range(ROWS - 3):
        for c in range(3, COLS):
            window = [board[r + i][c - i] for i in range(4)]
            score += evaluate_window(window, piece)

    return score


def alphabeta(board, depth, alpha, beta, maximizingPlayer):
    """Реализация алгоритма альфа-бета отсечения."""
    valid_locations = [c for c in range(COLS) if is_valid_location(board, c)]
    is_terminal = is_terminal_node(board)

    if depth == 0 or is_terminal:
        if is_terminal:
            if winning_move(board, AI):
                return (None, math.inf)
            elif winning_move(board, PLAYER):
                return (None, -math.inf)
            return (None, 0)  # Ничья

        return (None, score_position(board, AI))

    if maximizingPlayer:
        value = -math.inf
        best_col = random.choice(valid_locations)
        for col in valid_locations:
            row = get_next_open_row(board, col)
            temp_board = [r[:] for r in board]
            drop_piece(temp_board, row, col, AI)
            new_score = alphabeta(temp_board, depth - 1, alpha, beta, False)[1]
            if new_score > value:
                value = new_score
                best_col = col
            alpha = max(alpha, value)
            if alpha >= beta:
                break
        return best_col, value
    else:
        value = math.inf
        best_col = random.choice(valid_locations)
        for col in valid_locations:
            row = get_next_open_row(board, col)
            temp_board = [r[:] for r in board]
            drop_piece(temp_board, row, col, PLAYER)
            new_score = alphabeta(temp_board, depth - 1, alpha, beta, True)[1]
            if new_score < value:
                value = new_score
                best_col = col
            beta = min(beta, value)
            if alpha >= beta:
                break
        return best_col, value


def parse_column_number_from_input(value: str):
    return next(re.finditer(GET_INPUT_COLUMN_REGEX, value)).group()


def get_user_move():
    """Получаем ход пользователя"""
    while True:
        user_input = input("Укажите колонку (0-6) или [q]uit > ")

        if user_input == "q":
            print("Goodbye!")
            os._exit(0)

        try:
            return int(parse_column_number_from_input(user_input))
        except StopIteration:
            print(f"'{user_input}' не содержит валидного значения!")


def play_game():
    board = create_board()
    print_board(board)
    game_over = False

    while not game_over:
        # Ход игрока
        col = get_user_move()

        if is_valid_location(board, col):
            row = get_next_open_row(board, col)
            drop_piece(board, row, col, PLAYER)
            if winning_move(board, PLAYER):
                print(f"{YELLOW_BOLD}Игрок выиграл:{RESET}")
                game_over = True

        print()
        print_board(board)
        print()

        # Ход AI
        if not game_over:
            col, _ = alphabeta(board, ALPHA_BETA_DEPTH, -math.inf, math.inf, True)
            if is_valid_location(board, col):
                row = get_next_open_row(board, col)
                drop_piece(board, row, col, AI)
                if winning_move(board, AI):
                    print(f"{YELLOW_BOLD}Победа ИИ:{RESET}")
                    game_over = True

            print_board(board)


if __name__ == "__main__":
    play_game()
