from flask import Flask, request, jsonify, send_file
import pymysql
import pandas as pd
import torch
from transformers import GPT2LMHeadModel, GPT2Tokenizer
import matplotlib.pyplot as plt
import io
import os

app = Flask(__name__)

db_conn = {
    'host': 'localhost',
    'user': 'jiyoung',
    'password': '071122',
    'database': 'sugarstop',
    'autocommit': True  # 자동커밋
}

def get_db():
    try:
        return pymysql.connect(**db_conn)
    except Exception as e:
        print(f"데이터베이스 연결 실패: {str(e)}")
        return None

# 당 섭취(g)
@app.route('/sugar', methods=['POST'])
def sugar():
    sugarG = request.json.get('sugarG', 0)
    db_conn = get_db()
    cursor = db_conn.cursor()
    
    cursor.execute("update diet set sugarG = sugarG + %s where id = 1", (sugarG,))
    cursor.execute("select sugarG from diet where id = 1")
    sugarGG = cursor.fetchone()
    
    db_conn.commit()
    db_conn.close()
    
    return jsonify({
        'status': 'success',
        'message': 'Sugar consumption updated successfully',
        'data': {'upd_sugarG': sugarGG[0]}
    }), 200

# BMI 계산
def bmi(user_bmi):
    if user_bmi < 18.5:
        return 30
    elif 18.5 <= user_bmi < 24.9:
        return 25
    elif 25 <= user_bmi < 29.9:
        return 20
    else:
        return 15

@app.route('/bmi', methods=['POST'])
def sugar_bmi():
    data = request.get_json()
    userid = data.get('id')
    w = data.get('weight')
    h = data.get('height')

    if not userid or not w or not h:
        return jsonify({
            'status': 'error',
            'message': 'id, weight, and height are required'
        }), 400

    h_meter = h / 100.0
    bmi_value = w / (h_meter ** 2)
    sugar_bmi_result = bmi(bmi_value)

    db_conn = get_db()
    cursor = db_conn.cursor()

    cursor.execute("update people set bmi = %s where id = %s", (bmi_value, userid))
    cursor.execute("select id, name, weight, height, bmi from people where id = %s", (userid,))
    userdata = cursor.fetchone()
    db_conn.commit()
    db_conn.close()

    return jsonify({
        'status': 'success',
        'message': 'BMI calculation and update successful',
        'data': {
            'id': userdata[0],
            'name': userdata[1],
            'weight': userdata[2],
            'height': userdata[3],
            'bmi': userdata[4],
            'sugar_bmi_result': sugar_bmi_result
        }
    }), 200

# 챗봇
chat_name = "gpt2"
token = GPT2Tokenizer.from_pretrained(chat_name)
chat_model = GPT2LMHeadModel.from_pretrained(chat_name)
user_chat = {}

def c_chat(user_input, userid):
    if userid not in user_chat:
        user_chat[userid] = []
    
    chat_list = user_chat[userid]
    chat_list.append(f"User: {user_input}")
    text = "\n".join(chat_list) + "\nBot:"
    tokenid = token.encode(text, return_tensors="pt")

    put = chat_model.generate(tokenid, max_length=100, pad_token_id=token.eos_token_id, do_sample=True, top_k=50, top_p=0.95)
    result_text = token.decode(put[:, tokenid.shape[-1]:][0], skip_special_tokens=True)
    chat_list.append(f"Bot: {result_text}")
    user_chat[userid] = chat_list[-10:]

    return result_text

@app.route("/chat", methods=["POST"])
def chat_route():
    data = request.get_json()
    u_input = data.get("message")
    userid = data.get("user_id", "default_user")

    if not u_input:
        return jsonify({
            'status': 'error',
            'message': 'Message is required'
        }), 400

    response = c_chat(u_input, userid)
    return jsonify({
        'status': 'success',
        'message': 'Chatbot response generated successfully',
        'data': {'response': response}
    })

# 음식 먹은 횟수
@app.route('/increment', methods=['POST'])
def increment_counter():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("update counter set count = count + 1 where id = 1")
    cursor.execute("select count from counter where id = 1")
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return jsonify({
        'status': 'success',
        'message': 'Counter incremented successfully',
        'data': {'count': result[0]}
    })

@app.route('/get_count', methods=['GET'])
def get_count():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("select count from counter where id = 1")
    result = cursor.fetchone()
    cursor.close()
    conn.close()
    return jsonify({
        'status': 'success',
        'message': 'Counter retrieved successfully',
        'data': {'count': result[0] if result else 0}
    })

# 음식의 당(g) 계산
@app.route('/get_sugar', methods=['POST'])
def get_sugar():
    food_name = request.json.get('food_name')
    food_g = request.json.get('food_g', 1)

    try:
        excel = pd.read_excel("sugarstopData.xlsx")
    except FileNotFoundError:
        return jsonify({
            'status': 'error',
            'message': '엑셀 파일을 찾을 수 없습니다.'
        }), 500
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'엑셀 파일 로드 실패: {str(e)}'
        }), 500
    result = excel[excel['음식 이름'] == food_name]

    if not result.empty:
        sugar_food_g = result.iloc[0]['당류(g)']
        total = sugar_food_g * food_g
        return jsonify({
            'status': 'success',
            'message': 'Sugar content calculation successful',
            'data': {
                'food_name': food_name,
                'sugar_food_g': sugar_food_g,
                'total': total
            }
        }), 200
    else:
        return jsonify({
            'status': 'error',
            'message': '음식을 찾을 수 없습니다.'
        }), 404

# 그래프 생성
@app.route('/graph', methods=['GET'])
def create():
    userid = request.args.get('userid')
    if not userid:
        return jsonify({
            'status': 'error',
            'message': 'userid is required'
        }), 400

    db_conn = get_db()
    cursor = db_conn.cursor()
    
    cursor.execute("select sugarG from diet where userid = %s", (userid,))
    u_sugar = cursor.fetchone()
    if not u_sugar:
        return jsonify({
            'status': 'error',
            'message': 'No data found for the user'
        }), 404
    
    cursor.execute("select bmi from people where id = %s", (userid,))
    bmi_data = cursor.fetchone()
    if not bmi_data:
        return jsonify({
            'status': 'error',
            'message': 'No BMI data found for the user'
        }), 404

    bmi_value = bmi_data[0]
    avg = bmi(bmi_value)

    list = ['User Intake', 'Average Recommended']
    v = [u_sugar[0], avg]
    plt.figure(figsize=(6, 4))
    plt.bar(list, v, color=['blue', 'green'])
    plt.title('Sugar Consumption vs Recommended')
    plt.ylabel('Sugar (g)')
    plt.tight_layout()

    img = "sugar_graph.png"
    try:
        plt.savefig(img)
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'그래프 저장 실패: {str(e)}'
        }), 500
    finally:
        plt.close()

    response = send_file(img, mimetype='image/png')
    os.remove(img)
    return jsonify({
        'status': 'success',
        'message': 'Graph generated successfully',
        'data': {'image': response.data}
    })

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)
