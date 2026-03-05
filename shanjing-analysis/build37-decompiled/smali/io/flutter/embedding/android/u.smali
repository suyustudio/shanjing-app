.class public Lio/flutter/embedding/android/u;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lio/flutter/embedding/android/a0$d;


# instance fields
.field private final a:Li0/d;

.field private final b:Lio/flutter/embedding/android/a0$b;


# direct methods
.method public constructor <init>(Li0/d;)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lio/flutter/embedding/android/a0$b;

    invoke-direct {v0}, Lio/flutter/embedding/android/a0$b;-><init>()V

    iput-object v0, p0, Lio/flutter/embedding/android/u;->b:Lio/flutter/embedding/android/a0$b;

    iput-object p1, p0, Lio/flutter/embedding/android/u;->a:Li0/d;

    return-void
.end method

.method public static synthetic b(Lio/flutter/embedding/android/a0$d$a;Z)V
    .locals 0

    invoke-static {p0, p1}, Lio/flutter/embedding/android/u;->c(Lio/flutter/embedding/android/a0$d$a;Z)V

    return-void
.end method

.method private static synthetic c(Lio/flutter/embedding/android/a0$d$a;Z)V
    .locals 0

    invoke-interface {p0, p1}, Lio/flutter/embedding/android/a0$d$a;->a(Z)V

    return-void
.end method


# virtual methods
.method public a(Landroid/view/KeyEvent;Lio/flutter/embedding/android/a0$d$a;)V
    .locals 5

    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I

    move-result v0

    const/4 v1, 0x0

    const/4 v2, 0x1

    if-eqz v0, :cond_0

    if-eq v0, v2, :cond_0

    invoke-interface {p2, v1}, Lio/flutter/embedding/android/a0$d$a;->a(Z)V

    return-void

    :cond_0
    iget-object v3, p0, Lio/flutter/embedding/android/u;->b:Lio/flutter/embedding/android/a0$b;

    invoke-virtual {p1}, Landroid/view/KeyEvent;->getUnicodeChar()I

    move-result v4

    invoke-virtual {v3, v4}, Lio/flutter/embedding/android/a0$b;->a(I)Ljava/lang/Character;

    move-result-object v3

    new-instance v4, Li0/d$b;

    invoke-direct {v4, p1, v3}, Li0/d$b;-><init>(Landroid/view/KeyEvent;Ljava/lang/Character;)V

    if-eqz v0, :cond_1

    const/4 v1, 0x1

    :cond_1
    iget-object p1, p0, Lio/flutter/embedding/android/u;->a:Li0/d;

    new-instance v0, Lio/flutter/embedding/android/t;

    invoke-direct {v0, p2}, Lio/flutter/embedding/android/t;-><init>(Lio/flutter/embedding/android/a0$d$a;)V

    invoke-virtual {p1, v4, v1, v0}, Li0/d;->e(Li0/d$b;ZLi0/d$a;)V

    return-void
.end method
