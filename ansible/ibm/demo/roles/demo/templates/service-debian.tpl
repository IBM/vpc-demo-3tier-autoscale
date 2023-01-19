[Service]
Environment="FRONT_BACK={{ demo_role }}"
Environment="REMOTE_URL=http://{{ demo_lb_back }}:{{ demo_port }}"
WorkingDirectory={{ demo_dir }}
ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port {{ demo_port }} --workers 10
