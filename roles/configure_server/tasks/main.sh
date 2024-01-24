 tasks:
    - name: Создание пользователей
      user:
        name: "{{ item }}"
      loop:
        - user1
        - user2
        - user3

    - name: Выдача прав sudo
      become: true
      lineinfile:
        dest: /etc/sudoers
        line: "{{ item }} ALL=(ALL) NOPASSWD: ALL"
      loop:
        - user1
        - user2
        - user3

    - name: Создание переменных окружения
      become: true
      lineinfile:
        dest: /home/{{ item }}/.bashrc
        line: "export USERNAME={{ item }}"
      loop:
        - user1
        - user2
        - user3

    - name: Создание текстового файла
      become: true
      template:
        src: template.txt.j2
        dest: "/home/{{ item }}/{{ inventory_hostname }}_{{ item }}.txt"
      loop:
        - user1
        - user2
        - user3

    - name: Создание новой группы
      group:
        name: new_group

    - name: Добавление пользователей в группу
      user:
        name: "{{ item }}"
        groups: new_group
      loop:
        - user1
        - user2
        - user3

    - name: Установка прав на каталог
      become: true
      file:
        path: /etc/test_shell
        state: directory
        mode: 0775
        group: new_group

    - name: Создание bash-скрипта
      become: true
      template:
        src: script.sh.j2
        dest: /root/change_passwords.sh

    - name: Выполнение bash-скрипта
      become: true
      shell: /root/change_passwords.sh

    - name: Запрет подключения по ssh
      become: true
      lineinfile:
        dest: /home/{{ item }}/.ssh/authorized_keys
        regexp: '^ssh-rsa'
        state: absent
      loop:
        - user1
        - user2
        - user3

    - name: Очистка настроек
      become: true
      tags: cleanup
      command: echo "Очистка выполнена"

