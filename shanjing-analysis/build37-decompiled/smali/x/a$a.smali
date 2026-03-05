.class Lx/a$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/c$a;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lx/a;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lx/a;


# direct methods
.method constructor <init>(Lx/a;)V
    .locals 0

    iput-object p1, p0, Lx/a$a;->a:Lx/a;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public a(Ljava/nio/ByteBuffer;Lj0/c$b;)V
    .locals 1

    iget-object p2, p0, Lx/a$a;->a:Lx/a;

    sget-object v0, Lj0/s;->b:Lj0/s;

    invoke-virtual {v0, p1}, Lj0/s;->c(Ljava/nio/ByteBuffer;)Ljava/lang/String;

    move-result-object p1

    invoke-static {p2, p1}, Lx/a;->h(Lx/a;Ljava/lang/String;)Ljava/lang/String;

    iget-object p1, p0, Lx/a$a;->a:Lx/a;

    invoke-static {p1}, Lx/a;->i(Lx/a;)Lx/a$d;

    move-result-object p1

    if-eqz p1, :cond_0

    iget-object p1, p0, Lx/a$a;->a:Lx/a;

    invoke-static {p1}, Lx/a;->i(Lx/a;)Lx/a$d;

    move-result-object p1

    iget-object p2, p0, Lx/a$a;->a:Lx/a;

    invoke-static {p2}, Lx/a;->g(Lx/a;)Ljava/lang/String;

    move-result-object p2

    invoke-interface {p1, p2}, Lx/a$d;->a(Ljava/lang/String;)V

    :cond_0
    return-void
.end method
