dofile "/lua/creditinals.lua"
ngx.header["Content-Type"] = "text/html"
ngx.say([[
<head>
<meta charset=utf8 />
<title>]]..title..[[</title>
]]..favicon_tag..[[
</head>

<style>
.form_auth_block{
    width: 500px;
    height: 500px;
    margin: 0 auto;
    background-size: cover;
    border-radius: 4px;
}
.form_auth_block_content{
  padding-top: 15%;
}
.form_auth_block_head_text{
    display: block;
    text-align: center;
    padding: 10px;
    font-size: 20px;
    font-weight: 600;
    background: #ffffff;
    opacity: 0.7;
}
.form_auth_block label{
    display: block;
    text-align: center;
    padding: 10px;
    background: #ffffff;
    opacity: 0.7;
    font-weight: 600;
    margin-bottom: 10px;
    margin-top: 10px;
}
.form_auth_block input{
  display: block;
  margin: 0 auto;
  width: 80%;
  height: 45px;
  border-radius: 10px;
  outline: none;
}
input:focus {
  color: #000000;
  border-radius: 10px;
  border: 2px solid #436fea;
}
.form_auth_button{
    display: block;
    width: 80%;
    margin: 0 auto;
    margin-top: 10px;
    border-radius: 10px;
    height: 35px;
    cursor: pointer;
}
::-webkit-input-placeholder {color:#3f3f44; padding-left: 10px;}
::-moz-placeholder          {color:#3f3f44; padding-left: 10px;}
:-moz-placeholder           {color:#3f3f44; padding-left: 10px;}
:-ms-input-placeholder      {color:#3f3f44; padding-left: 10px;}

</style>

<div class="form_auth_block">
  <div class="form_auth_block_content">
    <p class="form_auth_block_head_text">]]..title..[[</p>
    <form class="form_auth_style" action="]]..auth_location..[[" method="post">
      <label>Login</label>
      <input type="text" name="username" placeholder="Login" required >
      <label>Password</label>
      <input type="password" name="password" placeholder="Password" required >
      <button class="form_auth_button" type="submit" name="form_auth_submit">Authorization</button>
    </form>
  </div>
</div>
]])